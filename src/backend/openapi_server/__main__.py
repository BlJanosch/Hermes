import connexion
from flask_cors import CORS
from openapi_server import encoder


def main():
    app = connexion.App(__name__, specification_dir='../openapi_server/openapi/')
    app.app.json_encoder = encoder.JSONEncoder

    CORS(app.app)

    app.add_api('openapi.yaml',
                arguments={'title': 'Kaffeemaschine API'},
                pythonic_params=True)

    app.run(port=8080)


if __name__ == '__main__':
    main()
