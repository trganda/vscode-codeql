# Part I - Setup of CodeQL

It's quite sample to use `QL` in vscode, you need to install [vscode](https://www.bing.com/ck/a?!&&p=39222d8d60a6c31adfca11627b6ac79db9fb9aa336671844a841a401e40a0809JmltdHM9MTY0Nzc4MDAwMiZpZ3VpZD0zM2M3NDZlYS1lYjg3LTQzZGQtYWM5MC1iNjBkZmI3NmRkZmYmaW5zaWQ9NTE0Ng&ptn=3&fclid=dc9c551b-a84a-11ec-9b6a-984c79a9fe7c&u=a1aHR0cHM6Ly9jb2RlLnZpc3VhbHN0dWRpby5jb20vP21zY2xraWQ9ZGM5YzU1MWJhODRhMTFlYzliNmE5ODRjNzlhOWZlN2M&ntb=1) first.

## CodeQL Installtion

Before using codeql for code analysis, we need install CodeQL CLI(CodeQL Command Line Interface) tools. Create a local folder to store it first,

```bash
$ mkdir ~/.codeql
```

or you can place it to any position where you want.

### Download CodeQL CLI ZIP File

Download the CLI tool form the [CodeQL CLI release page](https://github.com/github/codeql-cli-binaries/releases).

> There are several different versions of the CLI available to download, depending on your use case:
>
> * If you want to use the most up to date CodeQL tools and features, download the version tagged latest.
> * If you want to create CodeQL databases to upload to LGTM Enterprise, download the version that is compatible with the relevant LGTM Enterprise version number.

```bash
$ wget -O codeql-{platform}.zip https://github.com/github/codeql-cli-binaries/releases/download/{tag}/codeql-{platform}.zip
```

### Extract ZIP to Folder

After download the tool, unpack it to the directory you created.

```bash
$ unzip -d ~/.codeql codeql-{platform}.zip
```

### Link CodeQL CLI Tool to PATH

Now, it's better link the `~/.codeql/codeql` to a directory where the `$PATH` can found.

```bash
$ sudo ln -s ~/.codeql/codeql /usr/local/bin/codeql
```

### Obtain the Local Copy of CodeQL Queries Library

The [CodeQL repository](https://github.com/github/codeql) contains the queries and libraries required for CodeQL analysis of C/C++, C#, Java, JavaScript/TypeScript, Python, and Ruby. Clone a copy of this repository into `.codeql`.

To avoid conflicting with the CodeQL CLI tool, rename the clone repository folder to `codeql-repo`

```bash
$ cd ~/.codeql
$ git clone https://github.com/github/codeql codeql-repo
```

If you want to work with Go analysis, clone [CodeQL for Go repository](https://github.com/github/codeql-go/) to `.codeql` 

### Check

Run

```bash
$ codeql resolve languages
# Output
# cpp (/opt/codeql/cpp)
# csharp (/opt/codeql/csharp)
# csv (/opt/codeql/csv)
# go is found in 2 same-priority locations, so attempts to resolve it will fail:
#    /opt/codeql/go
#    /opt/codeql/codeql-go
# html (/opt/codeql/html)
# java (/opt/codeql/java)
# javascript (/opt/codeql/javascript)
# properties (/opt/codeql/properties)
# python (/opt/codeql/python)
# ruby (/opt/codeql/ruby)
# xml (/opt/codeql/xml)
```

If you have see something like that, the codeql has been installed successfuly.
