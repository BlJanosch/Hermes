import unittest
from unittest.mock import patch, MagicMock
import datetime

import openapi_server.controllers.erfolge_controller as ec
from openapi_server.models.user_erfolg import UserErfolg
from openapi_server.models.ziel_erreicht import ZielErreicht


class TestErfolgeController(unittest.TestCase):

    @patch("openapi_server.controllers.erfolge_controller.get_connection")
    @patch("connexion.request", autospec=True)
    def test_add_erfolg_success(self, mock_request, mock_get_connection):
        mock_request.is_json = True
        mock_request.get_json.return_value = {"uid": 1, "eid": 2}

        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_get_connection.return_value = mock_conn
        mock_conn.cursor.return_value = mock_cursor

        response, status = ec.add_erfolg(None)
        self.assertEqual(status, 201)
        mock_cursor.execute.assert_called_once()
        mock_conn.commit.assert_called_once()

    @patch("connexion.request", autospec=True)
    def test_add_erfolg_invalid_input(self, mock_request):
        mock_request.is_json = False
        response = ec.add_erfolg({"some": "data"})
        self.assertEqual(response[1], 400)

    @patch("openapi_server.controllers.erfolge_controller.get_connection")
    @patch("connexion.request", autospec=True)
    def test_add_erreichtesziel_success(self, mock_request, mock_get_connection):
        mock_request.is_json = True
        mock_request.get_json.return_value = {"uid": 1, "zid": 5}

        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_get_connection.return_value = mock_conn
        mock_conn.cursor.return_value = mock_cursor
        mock_cursor.fetchone.return_value = None

        response = ec.add_erreichtesziel(None)
        self.assertEqual(response[1], 201)
        mock_cursor.execute.assert_called()

    @patch("connexion.request", autospec=True)
    def test_add_erreichtesziel_invalid_input(self, mock_request):
        mock_request.is_json = False
        response = ec.add_erreichtesziel({})
        self.assertEqual(response[1], 400)

    @patch("openapi_server.controllers.erfolge_controller.get_connection")
    def test_get_ziele_success(self, mock_get_connection):
        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_get_connection.return_value = mock_conn
        mock_conn.cursor.return_value = mock_cursor
        mock_cursor.fetchall.return_value = [{
            "id": 1,
            "name": "Zugspitze",
            "hoehe": 2962,
            "schwierigkeit": 3,
            "bild": "bild.png",
            "lat": 47.4,
            "lng": 10.9,
            "datum": str(datetime.date.today())
        }]

        result, status = ec.get_ziele(1)
        self.assertEqual(status, 200)
        self.assertEqual(result[0].name, "Zugspitze")

    @patch("openapi_server.controllers.erfolge_controller.get_connection")
    def test_get_erfolge_success(self, mock_get_connection):
        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_get_connection.return_value = mock_conn
        mock_conn.cursor.return_value = mock_cursor
        mock_cursor.fetchall.return_value = [
            {"id": 1, "name": "100km", "beschreibung": "Laufe 100km", "schwierigkeit": 2}
        ]

        result, status = ec.get_erfolge(1)
        self.assertEqual(status, 200)
        self.assertEqual(result[0].name, "100km")

    @patch("openapi_server.controllers.erfolge_controller.get_connection")
    def test_get_allerfolge_success(self, mock_get_connection):
        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_get_connection.return_value = mock_conn
        mock_conn.cursor.return_value = mock_cursor
        mock_cursor.fetchall.return_value = [
            {"id": 4, "name": "Profi", "beschreibung": "Alle geschafft"}
        ]

        result, status = ec.get_allerfolge()
        self.assertEqual(status, 200)
        self.assertEqual(result[0].id, 4)

    @patch("openapi_server.controllers.erfolge_controller.get_connection")
    def test_check_erfolge_unlocks_new(self, mock_get_connection):
        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_get_connection.return_value = mock_conn
        mock_conn.cursor.return_value = mock_cursor

        mock_cursor.fetchone.side_effect = [{
            "kmgelaufen": 150,
            "hoehenmeter": 4000,
            "ziele_erreicht": 10
        }]
        mock_cursor.fetchall.return_value = [{"erfolg_id": 99}]

        result, status = ec.check_erfolge(1)
        self.assertEqual(status, 200)
        self.assertTrue(result)

    @patch("openapi_server.controllers.erfolge_controller.get_connection")
    def test_get_ziel_success(self, mock_get_connection):
        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_get_connection.return_value = mock_conn
        mock_conn.cursor.return_value = mock_cursor

        mock_cursor.fetchone.return_value = {
            "id": 5,
            "name": "Mount Everest",
            "hoehe": 8848,
            "schwierigkeit": 5,
            "bild": "everest.png",
            "lat": 27.9881,
            "lng": 86.925
        }

        result, status = ec.get_ziel(5)
        self.assertEqual(status, 200)
        self.assertEqual(result.name, "Mount Everest")


if __name__ == "__main__":
    unittest.main()
