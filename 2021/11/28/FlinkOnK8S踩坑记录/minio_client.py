import os

from minio import Minio


class MinioClient():
    def __init__(self):
        endpoint = os.environ['KUBERNETES_S3_ENDPOINT']
        access_key = os.environ['KUBERNETES_S3_ACCESS_KEY']
        secret_key = os.environ['KUBERNETES_S3_SECRET_KEY']
        bucket = os.environ['KUBERNETES_S3_BUCKET']
        if endpoint is None or access_key is None or secret_key is None or bucket is None:
            raise Exception("minio client env not set correctly")
        self.client = Minio(
            endpoint, access_key=access_key, secret_key=secret_key, secure=False
        )
        self.bucket = bucket
        self.create_bucket(self.bucket)

    def create_bucket(self, bucket):
        found = self.client.bucket_exists(self.bucket)
        if not found:
            client.make_bucket(self.bucket)
        else:
            print("Bucket '%s' already exists" % self.bucket)

    def upload(self, src, dest):
        self.client.fput_object(self.bucket, src, dest)
        print("%s put success" % dest)

    def download(self, src, dest):
        self.client.fget_object(self.bucket, src, dest)
        print("%s get success" % src)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="minio client")
    parser.add_argument(
        "--src", type=str, help="src file path", required=True,
    )
    parser.add_argument(
        "--dest", type=str, help="destination file path", required=True,
    )

    parser.print_help()
    args = parser.parse_args()
    print(args)
    client = MinioClient()
    client.download(args.src, args.dest)
