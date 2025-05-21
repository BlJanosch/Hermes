import connexion
from typing import Dict
from typing import Tuple
from typing import Union

from openapi_server.models.erfolg import Erfolg  # noqa: E501
from openapi_server.models.user_erfolg import UserErfolg  # noqa: E501
from openapi_server.models.ziel import Ziel  # noqa: E501
from openapi_server.models.ziel_erreicht import ZielErreicht  # noqa: E501
from openapi_server import util


def add_erfolg(body):  # noqa: E501
    """Neuen Erfolg zum User hinzufügen

     # noqa: E501

    :param user_erfolg: 
    :type user_erfolg: dict | bytes

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    user_erfolg = body
    if connexion.request.is_json:
        user_erfolg = UserErfolg.from_dict(connexion.request.get_json())  # noqa: E501
    return 'do some magic!'


def add_erreichtesziel(body):  # noqa: E501
    """Neues erreichtes Ziel hinzufügen

     # noqa: E501

    :param ziel_erreicht: 
    :type ziel_erreicht: dict | bytes

    :rtype: Union[None, Tuple[None, int], Tuple[None, int, Dict[str, str]]
    """
    ziel_erreicht = body
    if connexion.request.is_json:
        ziel_erreicht = ZielErreicht.from_dict(connexion.request.get_json())  # noqa: E501
    return 'do some magic!'


def erfolg_get(user_id):  # noqa: E501
    """Alle erreichten Ziele vom jeweiligen User erhalten

     # noqa: E501

    :param user_id: 
    :type user_id: int

    :rtype: Union[List[Ziel], Tuple[List[Ziel], int], Tuple[List[Ziel], int, Dict[str, str]]
    """
    return 'do some magic!'


def get_erfolge(user_id):  # noqa: E501
    """Gibt alle Erfolge vom jeweiligen User zurück

     # noqa: E501

    :param user_id: 
    :type user_id: int

    :rtype: Union[List[Erfolg], Tuple[List[Erfolg], int], Tuple[List[Erfolg], int, Dict[str, str]]
    """
    return 'do some magic!'
