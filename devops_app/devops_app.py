from flask import Flask
app = Flask(__name__)


@app.route('/')
def dev_ops():
    return 'DevOps App - Terraform, Kubernetes, GithubActions'


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
