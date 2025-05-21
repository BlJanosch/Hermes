import unittest

from flask import json

from openapi_server.models.erfolg import Erfolg  # noqa: E501
from openapi_server.models.user_erfolg import UserErfolg  # noqa: E501
from openapi_server.models.ziel import Ziel  # noqa: E501
from openapi_server.models.ziel_erreicht import ZielErreicht  # noqa: E501
from openapi_server.test import BaseTestCase


class TestErfolgeController(BaseTestCase):
    """ErfolgeController integration test stubs"""

    def test_add_erfolg(self):
        """Test case for add_erfolg

        Neuen Erfolg zum User hinzufügen
        """
        user_erfolg = {"Status":True,"UID":0,"EID":6}
        headers = { 
            'Content-Type': 'application/json',
        }
        response = self.client.open(
            '/erfolg/add_erfolg',
            method='POST',
            headers=headers,
            data=json.dumps(user_erfolg),
            content_type='application/json')
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_add_erreichtesziel(self):
        """Test case for add_erreichtesziel

        Neues erreichtes Ziel hinzufügen
        """
        ziel_erreicht = {"UID":0,"Datum":"2000-01-23","ZID":6}
        headers = { 
            'Content-Type': 'application/json',
        }
        response = self.client.open(
            '/erfolg/add_erreichtesziel',
            method='POST',
            headers=headers,
            data=json.dumps(ziel_erreicht),
            content_type='application/json')
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_erfolg_get(self):
        """Test case for erfolg_get

        Alle erreichten Ziele vom jeweiligen User erhalten
        """
        query_string = [('userID', 56)]
        headers = { 
            'Accept': 'application/json',
        }
        response = self.client.open(
            '/erfolg/erreichteziele',
            method='GET',
            headers=headers,
            query_string=query_string)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_get_erfolge(self):
        """Test case for get_erfolge

        Gibt alle Erfolge vom jeweiligen User zurück
        """
        query_string = [('userID', 56)]
        headers = { 
            'Accept': 'application/json',
        }
        response = self.client.open(
            '/erfolg/get_erfolge',
            method='GET',
            headers=headers,
            query_string=query_string)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))


if __name__ == '__main__':
    unittest.main()
