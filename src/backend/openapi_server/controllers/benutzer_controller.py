import connexion
from typing import Dict
from typing import Tuple
from typing import Union

from openapi_server.models.user import User  # noqa: E501
from openapi_server.models.user_bestenliste import UserBestenliste  # noqa: E501
from openapi_server import util


def bestenliste(user_id, filter):  # noqa: E501
    """Bestenliste nach Filter abrufen

     # noqa: E501

    :param user_id: 
    :type user_id: int
    :param filter: 
    :type filter: str

    :rtype: Union[List[UserBestenliste], Tuple[List[UserBestenliste], int], Tuple[List[UserBestenliste], int, Dict[str, str]]
    """
    return 'do some magic!'


def update_stats(body):  # noqa: E501
    """Aktualisiert die Statistiken eines Benutzers

     # noqa: E501

    :param user: 
    :type user: dict | bytes

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    user = body
    if connexion.request.is_json:
        user = User.from_dict(connexion.request.get_json())  # noqa: E501
    return 'do some magic!'


def user_login(benutzername, passwort):  # noqa: E501
    """Prüft, ob ein User existiert

     # noqa: E501

    :param benutzername: 
    :type benutzername: str
    :param passwort: 
    :type passwort: str

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    return 'do some magic!'


def user_register(body):  # noqa: E501
    """Neuen Benutzer registrieren

     # noqa: E501

    :param user: 
    :type user: dict | bytes

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    user = body
    if connexion.request.is_json:
        user = User.from_dict(connexion.request.get_json())  # noqa: E501
    return 'do some magic!'
