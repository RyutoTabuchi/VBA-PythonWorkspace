# VBA×Python プロジェクト

1つの目的に対するVBAとPythonのコードを、1つのGitリポジトリで管理します。
このテンプレートはコピー元です。作成タスクで生成したプロジェクト内で開発してください。

## 構成

```text
Project 名前/
  README.md
  requirements.txt
  .gitignore
  .vscode/settings.json
  Pysource/                Pythonコード（.py）
  VBsource/                エクスポートしたVBAコード
    ブック名/              .bas / .cls / .frm / .frx
  Sandbox/                 本番へ採用する前の試作・検証
  ブック名.xlsm            必要に応じて手動で配置
```

フォルダー名は `Pysource` と `VBsource` を使用します。各ソースフォルダー内で個別に `git init` しないでください。
`.git` と `.vscode/settings.json` は作成ツールがプロジェクト直下に生成します。
ブックやサンプルコード、VBAとPythonの呼び出し処理は自動作成しません。

## Python

Python 3.10以上とPython Launcher（`py`）を使用します。作成時に指定したインストール済みPythonのパスを設定し、仮想環境やパッケージは自動作成・導入しません。

1. 通常は `Workspace.code-workspace` またはワークスペース直下を開いたまま作業します。ターミナルでは対象の `Projects/Project 名前` に移動します。
2. `Python: Select Interpreter` で使用するPythonを確認します。以前の選択が残っている場合は、作成時に指定したPythonへ切り替えてください。
3. Pythonコードを `Pysource` に配置し、必要な外部パッケージをルートの `requirements.txt` に記載します。

子フォルダー内の `.vscode/settings.json` は親ワークスペースには適用されません。生成したPython設定をそのまま使いたい場合に限り、プロジェクトフォルダーを別ウィンドウで開いてください。共通の作成・UserFormタスクはワークスペース側から利用します。

プロジェクト直下で実行します。`3.13` は作成時に指定したバージョン、`main.py` は実際のファイル名に置き換えてください。

```powershell
py -3.13 .\Pysource\main.py
py -3.13 -m pip install -r requirements.txt
```

パッケージ導入は必要な場合のみ実行します。システムPythonへのインストールは、同じPythonを使う他のプロジェクトにも影響します。

## VBA

Excelブックは必要に応じてプロジェクト直下に配置し、VBAソースを `VBsource/ブック名/` にエクスポートします。UserFormの `.frm` と `.frx` は同じ場所に保管します。

Excel VBA Syncを使用する場合、`Set Export Folder` にはこのプロジェクトの `VBsource` を指定します。出力前に対象ブックを確認してください。
ソースファイルを編集するだけではブック内のコードは変わりません。ブックへの反映は明示的に実行し、VBEでコンパイル・動作確認後にブックを保存してください。

VBAソースは種類別のフォルダーではなく、`VBsource/ブック名/` にまとめます。同期ツールによっては `VBsource/.excel-vba-sync-backups/ブック名/` に `.syncbase.json` が出力されます。ハッシュや取得日時などの同期管理情報だけを含むJSONは、VBAコード本体を復元できるバックアップではありません。実際にコードを含むバックアップとは区別してください。

CopilotがExcelを起動する、ブックを開く、マクロを実行する、ブックを変更・保存する場合は、対象ブックと操作内容を示し、事前に許可を確認します。読み取りの許可だけでは、実行や変更は行いません。

VBAからPythonを呼び出す場合は、実行するPythonのパスと、このプロジェクト内の `Pysource` を参照するよう実装します。PC固有の絶対パスをコードに固定せず、ブックの保存場所を基準にしてください。

## 試作・検証

本番採用前のコードは [Sandbox/README.md](Sandbox/README.md) の手順で管理します。本番ソースへの採用状況と実際の検証結果を記録し、未確認のコードを本番ブックへ取り込まないでください。

## Git

VBAとPythonはプロジェクト直下の共通リポジトリで管理します。作成時に初期ファイルをステージしますが、コミット・リモート登録・pushは実行しません。

```powershell
git status
git diff --cached
git commit -m "Initial project setup"
```

ブック（`.xlsm`、`.xlsb`、`.xlam`）、一時ファイル、秘密情報、Pythonキャッシュは既定でGit対象外です。ブック自体も履歴管理する場合は `.gitignore` を変更してください。VBAソースと `.frx` はGitで管理できます。