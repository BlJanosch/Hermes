import unittest
from unittest.mock import patch, AsyncMock
import asyncio

from openapi_server.__main__ import app
from openapi_server.controllers import benutzer_controller


class TestBenutzerController(unittest.TestCase):

    @patch('openapi_server.controllers.benutzer_controller.connexion.request')
    @patch('openapi_server.controllers.benutzer_controller.get_connection')
    def test_update_stats_success(self, mock_get_conn, mock_request):
        async def run():
            with app.test_request_context('/benutzer/stats', method='POST'):
                mock_request.is_json = True
                mock_request.get_json = AsyncMock(return_value={
                    "id": 1,
                    "kmgelaufen": 5.5,
                    "hoehenmeter": 100.0
                })

                mock_conn = AsyncMock()
                mock_get_conn.return_value = mock_conn
                mock_cursor = AsyncMock()
                mock_conn.cursor.return_value = mock_cursor
                mock_cursor.fetchone.return_value = (1,)  # user found

                result, status = await benutzer_controller.update_stats(None)

                self.assertEqual(status, 200)
                self.assertEqual(result, "Erfolg")

        asyncio.run(run())

    @patch('openapi_server.controllers.benutzer_controller.connexion.request')
    @patch('openapi_server.controllers.benutzer_controller.get_connection')
    def test_update_userdata_success(self, mock_get_conn, mock_request):
        async def run():
            with app.test_request_context('/benutzer/userdata', method='POST'):
                mock_request.is_json = True
                mock_request.get_json = AsyncMock(return_value={
                    "id": 1,
                    "kmgelaufen": 12.5,
                    "hoehenmeter": 200.0,
                    "passwort": "123",
                    "benutzername": "mockuser",
                    "profilbild": "pic.jpg"
                })

                mock_conn = AsyncMock()
                mock_get_conn.return_value = mock_conn
                mock_cursor = AsyncMock()
                mock_conn.cursor.return_value = mock_cursor
                mock_cursor.fetchone.return_value = (1,)  # user found

                result, status = await benutzer_controller.update_userdata(None)

                self.assertEqual(status, 200)
                self.assertEqual(result, "Erfolg")

        asyncio.run(run())

    def test_user_get_found(self):
        # synchroner Test, kein Request Kontext nötig
        result, status = benutzer_controller.user_get(1)
        self.assertEqual(status, 200)
        self.assertIn("benutzername", result)

    def test_user_get_not_found(self):
        # synchroner Test, kein Request Kontext nötig
        result, status = benutzer_controller.user_get(999)
        self.assertEqual(status, 404)

    def test_user_login_found(self):
        result, status = benutzer_controller.user_login("admin", "admin123")
        self.assertEqual(status, 200)
        self.assertIn("id", result)

    def test_user_login_not_found(self):
        result, status = benutzer_controller.user_login("failuser", "pass")
        self.assertEqual(status, 401)

    @patch('openapi_server.controllers.benutzer_controller.connexion.request')
    @patch('openapi_server.controllers.benutzer_controller.get_connection')
    def test_user_register_conflict(self, mock_get_conn, mock_request):
        async def run():
            with app.test_request_context('/benutzer/register', method='POST'):
                mock_request.is_json = True
                mock_request.get_json = AsyncMock(return_value={
                    "benutzername": "admin",  # already exists
                    "passwort": "pass123"
                })

                mock_conn = AsyncMock()
                mock_get_conn.return_value = mock_conn
                mock_cursor = AsyncMock()
                mock_conn.cursor.return_value = mock_cursor
                mock_cursor.fetchone.return_value = (1,)  # username exists

                result, status = await benutzer_controller.user_register(None)

                self.assertEqual(status, 409)

        asyncio.run(run())

    @patch('openapi_server.controllers.benutzer_controller.connexion.request')
    @patch('openapi_server.controllers.benutzer_controller.get_connection')
    def test_user_register_success(self, mock_get_conn, mock_request):
        async def run():
            with app.test_request_context('/benutzer/register', method='POST'):
                mock_request.is_json = True
                mock_request.get_json = AsyncMock(return_value={
                    "benutzername": "newuser",
                    "passwort": "pass123"
                })

                mock_conn = AsyncMock()
                mock_get_conn.return_value = mock_conn
                mock_cursor = AsyncMock()
                mock_conn.cursor.return_value = mock_cursor
                mock_cursor.fetchone.return_value = None  # username not exists

                result, status = await benutzer_controller.user_register(None)

                self.assertEqual(status, 201)
                self.assertEqual(result, "Benutzer erfolgreich registriert")

        asyncio.run(run())


if __name__ == '__main__':
    unittest.main()
