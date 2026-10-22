#!/usr/bin/env python3

import argparse
import sys
import time
import unittest

START_TIMEOUT = 120  # seconds to wait for the container to be usable


def wait_for_container(container, timeout=START_TIMEOUT):
    print("Waiting for the container to be usable...")
    deadline = time.time() + timeout
    while True:
        container.reload()
        state = container.attrs.get("State", {})
        status = state.get("Status")
        if status in ("exited", "dead"):
            logs = container.logs().decode("utf-8", errors="replace")
            raise RuntimeError(
                f"The container stopped before it was usable (status={status}).\n{logs}"
            )
        if status == "running":
            try:
                if container.exec_run(["true"]).exit_code == 0:
                    print("The container is usable.")
                    return
            except Exception:
                pass
        if time.time() > deadline:
            logs = container.logs().decode("utf-8", errors="replace")
            raise RuntimeError(f"The container was not usable within {timeout}s.\n{logs}")
        time.sleep(2)


def run_tests(image_name, kind):
    import docker

    class TestAwscli(unittest.TestCase):
        @classmethod
        def setUpClass(cls):
            cls.client = docker.from_env()
            cls.container = cls.client.containers.run(
                image_name,
                detach=True,
                tty=True,
                command=["/bin/bash"],
            )
            wait_for_container(cls.container)

        @classmethod
        def tearDownClass(cls):
            cls.container.stop()
            cls.container.remove()

        def test_runs_as_unprivileged_user(self):
            print("Running the user test...")
            result = self.container.exec_run(["id", "-u"])
            uid = result.output.decode().strip()
            self.assertNotEqual(uid, "0", "The container runs as root")
            print("User test passed.")

        def test_the_command_is_there(self):
            print("Running the command test...")
            result = self.container.exec_run(["aws", "--version"])
            output = result.output.decode("utf-8", errors="replace")
            self.assertEqual(result.exit_code, 0, f"The command does not run: {output}")
            self.assertIn("aws-cli", output, f"The command is not the one of aws: {output}")
            print("Command test passed.")

        def test_the_entrypoint_runs_the_command(self):
            print("Running the entrypoint test...")
            if kind == "command":
                # The entrypoint runs the command of aws with the arguments.
                result = self.client.containers.run(
                    image_name,
                    remove=True,
                    stdout=True,
                    stderr=True,
                    command=["--version"],
                )
                output = result.decode("utf-8", errors="replace")
                self.assertIn("aws-cli", output, f"The command did not run: {output}")
            else:
                # The entrypoint runs the command that is given to it.
                result = self.client.containers.run(
                    image_name, remove=True, command=["/bin/echo", "the entrypoint works"]
                )
                output = result.decode("utf-8", errors="replace")
                self.assertIn("the entrypoint works", output, f"The command did not run: {output}")
            print("Entrypoint test passed.")

    print(f"Starting the container from the image '{image_name}'...")
    suite = unittest.TestLoader().loadTestsFromTestCase(TestAwscli)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    if not result.wasSuccessful():
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run the tests for the awscli images.")
    parser.add_argument(
        "--image",
        type=str,
        default="satishweb/awscli:draft-latest",
        help="The image that is tested",
    )
    parser.add_argument(
        "--kind",
        choices=["command", "shell"],
        default="command",
        help="The kind of the image that is tested",
    )
    args = parser.parse_args()

    run_tests(args.image, args.kind)
