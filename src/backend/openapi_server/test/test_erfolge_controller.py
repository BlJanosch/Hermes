import unittest
from flask import json
from openapi_server.test import BaseTestCase

class TestErfolgeController(BaseTestCase):
    """Integrationstests für ErfolgeController"""

    def test_add_erfolg(self):
        """POST /ui/erfolg/add_erfolg - Neuen Erfolg zum User hinzufügen"""
        user_erfolg = {
            "UID": 1,      # Beispiel-User-ID
            "EID": 2,      # Beispiel-Erfolg-ID
            "Status": True
        }
        response = self.client.open(
            '/ui/erfolg/add_erfolg',
            method='POST',
            headers={'Content-Type': 'application/json'},
            data=json.dumps(user_erfolg),
            content_type='application/json'
        )
        self.assertIn(response.status_code, [200, 201],
                      'Erfolg konnte nicht hinzugefügt werden. Response body: ' + response.data.decode('utf-8'))

    def test_add_erreichtesziel(self):
        """POST /ui/erfolg/add_erreichtesziel - Neues erreichtes Ziel hinzufügen"""
        ziel_erreicht = {
            "UID": 1,              # Beispiel-User-ID
            "ZID": 2,              # Beispiel-Ziel-ID
            "Datum": "2025-01-01"  # Beispiel-Datum (kann auch heute sein)
        }
        response = self.client.open(
            '/ui/erfolg/add_erreichtesziel',
            method='POST',
            headers={'Content-Type': 'application/json'},
            data=json.dumps(ziel_erreicht),
            content_type='application/json'
        )
        self.assertIn(response.status_code, [200, 201, 400],
                      'Erreichtes Ziel konnte nicht hinzugefügt werden oder existiert bereits. Response: ' + response.data.decode('utf-8'))

    def test_get_erreichte_ziele(self):
        """GET /ui/erfolg/erreichteziele - Alle erreichten Ziele vom jeweiligen User erhalten"""
        query_string = [('userID', 1)]
        response = self.client.open(
            '/ui/erfolg/erreichteziele',
            method='GET',
            headers={'Accept': 'application/json'},
            query_string=query_string
        )
        self.assert200(response, 'Fehler beim Abrufen der erreichten Ziele: ' + response.data.decode('utf-8'))

    def test_get_user_erfolge(self):
        """GET /ui/erfolg/get_erfolge - Alle Erfolge vom jeweiligen User"""
        query_string = [('userID', 1)]
        response = self.client.open(
            '/ui/erfolg/get_erfolge',
            method='GET',
            headers={'Accept': 'application/json'},
            query_string=query_string
        )
        self.assert200(response, 'Fehler beim Abrufen der Erfolge des Users: ' + response.data.decode('utf-8'))

    def test_get_alle_erfolge(self):
        """GET /ui/erfolg/get_allerfolge - Alle Erfolge abrufen"""
        response = self.client.open(
            '/ui/erfolg/get_allerfolge',
            method='GET',
            headers={'Accept': 'application/json'}
        )
        self.assert200(response, 'Fehler beim Abrufen aller Erfolge: ' + response.data.decode('utf-8'))

    def test_check_erfolge(self):
        """GET /ui/erfolg/check_erfolge - Prüfen ob ein neuer Erfolg erreicht wurde"""
        query_string = [('userID', 1)]
        response = self.client.open(
            '/ui/erfolg/check_erfolge',
            method='GET',
            headers={'Accept': 'application/json'},
            query_string=query_string
        )
        self.assert200(response, 'Fehler beim Prüfen neuer Erfolge: ' + response.data.decode('utf-8'))

    def test_get_ziel_by_id(self):
        """GET /ui/erfolg/get_ziel - Zielinformationen abrufen"""
        query_string = [('zielID', 1)]
        response = self.client.open(
            '/ui/erfolg/get_ziel',
            method='GET',
            headers={'Accept': 'application/json'},
            query_string=query_string
        )
        self.assertIn(response.status_code, [200, 404], 'Fehler beim Abrufen des Ziels: ' + response.data.decode('utf-8'))


if __name__ == '__main__':
    unittest.main()
