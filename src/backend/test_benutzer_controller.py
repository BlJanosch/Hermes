import unittest
from unittest.mock import patch, MagicMock
from openapi_server.controllers.benutzer_controller import user_get, update_userdata, update_stats, user_login, user_register
from openapi_server.models.user import User
import bcrypt
import json

class TestUserController(unittest.TestCase):

    def setUp(self):
        self.sample_user = User(
            id=1,
            kmgelaufen=10.0,
            hoehenmeter=100.0,
            passwort="marmelade",
            benutzername="marillenmatratze",
            profilbild="glas.jpg"
        )

    @patch("openapi_server.controllers.benutzer_controller.get_connection")
    def test_user_get_success(self, mock_get_connection):
        mock_cursor = MagicMock()
        mock_connection = MagicMock()
        mock_get_connection.return_value = mock_connection
        mock_connection.cursor.return_value = mock_cursor
        mock_cursor.fetchone.return_value = (1, 10.0, 100.0, "hashedpw", "testuser", "test.jpg")

        user, status = user_get(1)
        self.assertEqual(status, 200)
        self.assertEqual(user.id, 1)

    @patch("openapi_server.controllers.benutzer_controller.get_connection")
    def test_user_get_not_found(self, mock_get_connection):
        mock_cursor = MagicMock()
        mock_connection = MagicMock()
        mock_get_connection.return_value = mock_connection
        mock_connection.cursor.return_value = mock_cursor
        mock_cursor.fetchone.return_value = None

        result, status = user_get(999)
        self.assertEqual(status, 401)
        self.assertIn("message", result)

    @patch("openapi_server.controllers.benutzer_controller.connexion")
    @patch("openapi_server.controllers.benutzer_controller.get_connection")
    def test_update_userdata_success(self, mock_get_connection, mock_connexion):
        mock_cursor = MagicMock()
        mock_connection = MagicMock()
        mock_get_connection.return_value = mock_connection
        mock_connection.cursor.return_value = mock_cursor

        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = self.sample_user.to_dict()

        mock_cursor.fetchone.side_effect = [(1,)]

        response, status = update_userdata(self.sample_user)
        self.assertEqual(status, 200)
        self.assertEqual(response, "Erfolg")

    @patch("openapi_server.controllers.benutzer_controller.connexion")
    def test_update_userdata_invalid_input(self, mock_connexion):
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {"invalid": "data"}

        response, status = update_userdata({})
        self.assertEqual(status, 400)

    @patch("openapi_server.controllers.benutzer_controller.connexion")
    @patch("openapi_server.controllers.benutzer_controller.get_connection")
    def test_update_stats_success(self, mock_get_connection, mock_connexion):
        mock_cursor = MagicMock()
        mock_connection = MagicMock()
        mock_get_connection.return_value = mock_connection
        mock_connection.cursor.return_value = mock_cursor
        mock_cursor.fetchone.side_effect = [(1,), (10.0, 100.0)]

        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {"id": 1, "kmgelaufen": 5, "hoehenmeter": 50}

        response, status = update_stats({})
        self.assertEqual(status, 200)
        self.assertEqual(response, "Erfolg")

    @patch("openapi_server.controllers.benutzer_controller.connexion")
    def test_update_stats_missing_fields(self, mock_connexion):
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {"id": 1, "hoehenmeter": 50}

        response, status = update_stats({})
        self.assertEqual(status, 400)

    @patch("openapi_server.controllers.benutzer_controller.get_connection")
    def test_user_login_success(self, mock_get_connection):
        hashed = bcrypt.hashpw("secret".encode(), bcrypt.gensalt())
        mock_cursor = MagicMock()
        mock_connection = MagicMock()
        mock_get_connection.return_value = mock_connection
        mock_connection.cursor.return_value = mock_cursor
        mock_cursor.fetchone.side_effect = [(hashed.decode(),), (1,)]

        result, status = user_login("testuser", "secret")
        self.assertEqual(status, 200)
        self.assertEqual(result, 1)

    @patch("openapi_server.controllers.benutzer_controller.get_connection")
    def test_user_login_wrong_password(self, mock_get_connection):
        hashed = bcrypt.hashpw("wrong".encode(), bcrypt.gensalt())
        mock_cursor = MagicMock()
        mock_connection = MagicMock()
        mock_get_connection.return_value = mock_connection
        mock_connection.cursor.return_value = mock_cursor
        mock_cursor.fetchone.return_value = (hashed.decode(),)

        result, status = user_login("testuser", "secret")
        self.assertEqual(status, 404)
        self.assertEqual(result, -1)

    @patch("openapi_server.controllers.benutzer_controller.connexion")
    @patch("openapi_server.controllers.benutzer_controller.get_connection")
    def test_user_register_success(self, mock_get_connection, mock_connexion):
        mock_cursor = MagicMock()
        mock_connection = MagicMock()
        mock_get_connection.return_value = mock_connection
        mock_connection.cursor.return_value = mock_cursor

        mock_cursor.fetchone.side_effect = [None]

        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = self.sample_user.to_dict()

        response, status = user_register(self.sample_user)
        self.assertEqual(status, 200)
        self.assertEqual(response, "Erfolg")

    @patch("openapi_server.controllers.benutzer_controller.connexion")
    @patch("openapi_server.controllers.benutzer_controller.get_connection")
    def test_user_register_user_exists(self, mock_get_connection, mock_connexion):
        mock_cursor = MagicMock()
        mock_connection = MagicMock()
        mock_get_connection.return_value = mock_connection
        mock_connection.cursor.return_value = mock_cursor

        mock_cursor.fetchone.side_effect = [(1,)]

        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = self.sample_user.to_dict()

        response = user_register(self.sample_user)
        self.assertEqual(response, ("User existiert bereits", 409))

if __name__ == '__main__':
    unittest.main()
