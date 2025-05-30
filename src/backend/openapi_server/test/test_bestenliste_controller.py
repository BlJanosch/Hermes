import unittest

from flask import json

from openapi_server.models.user_bestenliste import UserBestenliste  # noqa: E501
from openapi_server.test import BaseTestCase


class TestBestenlisteController(BaseTestCase):
    """BestenlisteController integration test stubs"""

    def test_bestenliste(self):
        """Test case for bestenliste

        Bestenliste nach Filter abrufen
        """
        query_string = [('userID', 56),
                        ('filter', 'filter_example')]
        headers = { 
            'Accept': 'application/json',
        }
        response = self.client.open(
            '/ui/user/bestenliste',
            method='GET',
            headers=headers,
            query_string=query_string)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))


if __name__ == '__main__':
    unittest.main()
