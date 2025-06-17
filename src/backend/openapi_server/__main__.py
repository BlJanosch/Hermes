import connexion
from flask_cors import CORS
from openapi_server import encoder

app = connexion.App(__name__, specification_dir='../openapi_server/openapi/')
app.app.json_encoder = encoder.JSONEncoder

CORS(app.app)

app.add_api('openapi.yaml',
            arguments={'title': 'Hermes API'},
            pythonic_params=True)

def main():
    """
    @brief Startet den Server, bzw. die open erstellte Connexion App.
    """
    app.run(port=8080)


if __name__ == '__main__':
    main()
