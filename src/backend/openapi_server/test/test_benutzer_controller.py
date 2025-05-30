import unittest

from flask import json

from openapi_server.models.user import User  # noqa: E501
from openapi_server.test import BaseTestCase


class TestBenutzerController(BaseTestCase):
    """BenutzerController integration test stubs"""

    def test_update_stats(self):
        """Test case for update_stats

        Aktualisiert die Statistiken eines Benutzers
        """
        user = {"hoehenmeter":1.4658129805029452,"kmgelaufen":6.027456183070403,"Benutzername":"Benutzername","ID":0,"Profilbild":"Profilbild","Passwort":"Passwort"}
        headers = { 
            'Content-Type': 'application/json',
        }
        response = self.client.open(
            '/ui/user/update_stats',
            method='PUT',
            headers=headers,
            data=json.dumps(user),
            content_type='application/json')
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_user_login(self):
        """Test case for user_login

        Prüft, ob ein User existiert
        """
        query_string = [('benutzername', 'benutzername_example'),
                        ('passwort', 'passwort_example')]
        headers = { 
        }
        response = self.client.open(
            '/ui/user/login',
            method='GET',
            headers=headers,
            query_string=query_string)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_user_register(self):
        """Test case for user_register

        Neuen Benutzer registrieren
        """
        user = {"hoehenmeter":1.4658129805029452,"kmgelaufen":6.027456183070403,"Benutzername":"Benutzername","ID":0,"Profilbild":"Profilbild","Passwort":"Passwort"}
        headers = { 
            'Content-Type': 'application/json',
        }
        response = self.client.open(
            '/ui/user/register',
            method='POST',
            headers=headers,
            data=json.dumps(user),
            content_type='application/json')
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))


if __name__ == '__main__':
    unittest.main()
