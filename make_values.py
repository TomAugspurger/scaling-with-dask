import sys

if __name__ == "__main__":
    tag = sys.argv[1]
    with open("values.yaml.tpl") as f:
        template = f.read().format(tag=tag)

    with open("values.yaml", "w") as f:
        f.write(template)
