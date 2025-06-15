import unittest
from flask import json
from openapi_server.test import BaseTestCase

class TestBestenlisteController(BaseTestCase):
    """BestenlisteController integration test"""

    def test_bestenliste_kmgelaufen(self):
        """Test: Bestenliste nach Kilometer sortiert"""
        query_string = [('user_id', 1), ('filter_db', 'kmgelaufen')]
        headers = {'Accept': 'application/json'}
        response = self.client.open(
            '/ui/user/bestenliste',
            method='GET',
            headers=headers,
            query_string=query_string)
        self.assert200(response, 'Response: ' + response.data.decode('utf-8'))

    def test_bestenliste_hoehenmeter(self):
        """Test: Bestenliste nach Höhenmeter sortiert"""
        query_string = [('user_id', 1), ('filter_db', 'hoehenmeter')]
        headers = {'Accept': 'application/json'}
        response = self.client.open(
            '/ui/user/bestenliste',
            method='GET',
            headers=headers,
            query_string=query_string)
        self.assert200(response, 'Response: ' + response.data.decode('utf-8'))

    def test_bestenliste_berge(self):
        """Test: Bestenliste nach Anzahl Berge"""
        query_string = [('user_id', 1), ('filter_db', 'berge')]
        headers = {'Accept': 'application/json'}
        response = self.client.open(
            '/ui/user/bestenliste',
            method='GET',
            headers=headers,
            query_string=query_string)
        self.assert200(response, 'Response: ' + response.data.decode('utf-8'))

    def test_bestenliste_invalid_filter(self):
        """Test: Ungültiger Filterwert"""
        query_string = [('user_id', 1), ('filter_db', 'ungültig')]
        headers = {'Accept': 'application/json'}
        response = self.client.open(
            '/ui/user/bestenliste',
            method='GET',
            headers=headers,
            query_string=query_string)
        self.assertEqual(response.status_code, 400, 'Expected status 400 for invalid filter')

if __name__ == '__main__':
    unittest.main()
