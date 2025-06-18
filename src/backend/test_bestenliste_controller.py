import unittest
from unittest.mock import patch, MagicMock
from openapi_server.controllers.bestenliste_controller import bestenliste

from openapi_server.models.user_bestenliste import UserBestenliste

class TestBestenlisteController(unittest.TestCase):

    def setUp(self):
        self.valid_user_id = 5

    @patch("openapi_server.controllers.bestenliste_controller.get_connection")
    def test_bestenliste_hoehenmeter_success(self, mock_get_connection):
        mock_cursor = MagicMock()
        mock_connection = MagicMock()
        mock_get_connection.return_value = mock_connection
        mock_connection.cursor.return_value = mock_cursor
        mock_cursor.fetchall.return_value = [
            {"id": 1, "benutzername": "Anna", "profilbild": "pic1.jpg", "hoehenmeter": 1200, "kmgelaufen": 40},
            {"id": 2, "benutzername": "Ben", "profilbild": "pic2.jpg", "hoehenmeter": 1100, "kmgelaufen": 38},
        ]

        result, status_code = bestenliste(self.valid_user_id, "hoehenmeter")

        self.assertEqual(status_code, 200)
        self.assertIsInstance(result, list)
        self.assertEqual(result[0].platzierung, 1)
        self.assertEqual(result[0].id, 1)
        self.assertEqual(result[1].platzierung, 2)

    def test_bestenliste_missing_parameters(self):
        result, status = bestenliste(None, None)
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    def test_bestenliste_invalid_filter(self):
        result, status = bestenliste(self.valid_user_id, "ungültig")
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch("openapi_server.controllers.bestenliste_controller.get_connection")
    def test_bestenliste_berge_filter(self, mock_get_connection):
        mock_cursor = MagicMock()
        mock_connection = MagicMock()
        mock_get_connection.return_value = mock_connection
        mock_connection.cursor.return_value = mock_cursor
        mock_cursor.fetchall.return_value = [
            {"id": 3, "benutzername": "Clara", "profilbild": "pic3.jpg", "hoehenmeter": 800, "kmgelaufen": 30, "anzahlBerge": 5},
            {"id": 4, "benutzername": "David", "profilbild": "pic4.jpg", "hoehenmeter": 700, "kmgelaufen": 25, "anzahlBerge": 4},
        ]

        result, status_code = bestenliste(self.valid_user_id, "berge")
        self.assertEqual(status_code, 200)
        self.assertEqual(result[0].anzahlBerge, 5)
        self.assertEqual(result[1].anzahlBerge, 4)

    @patch("openapi_server.controllers.bestenliste_controller.get_connection")
    def test_bestenliste_user_not_in_top_10_added(self, mock_get_connection):
        mock_cursor = MagicMock()
        mock_connection = MagicMock()
        mock_get_connection.return_value = mock_connection
        mock_connection.cursor.return_value = mock_cursor

        mock_cursor.fetchall.return_value = [
            {"id": i, "benutzername": f"User{i}", "profilbild": f"pic{i}.jpg", "hoehenmeter": 1000-i, "kmgelaufen": 50}
            for i in range(1, 12)
        ]

        result, status_code = bestenliste(11, "hoehenmeter")

        self.assertEqual(status_code, 200)
        self.assertEqual(len(result), 11)
        self.assertEqual(result[-1].id, 11)

if __name__ == "__main__":
    unittest.main()
