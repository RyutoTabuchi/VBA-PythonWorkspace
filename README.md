# VBA×Python ワークスペース

VBAとPythonを使うプロジェクトを、共通のソース構成・ドキュメント・Git履歴で管理します。作成できるのはVBA×Pythonプロジェクト1種類です。

## 統合プロジェクトの構成

```text
Projects/
  _Template_Combined/       統合用テンプレート
  Project 名前/
    README.md              共通の目的・実行方法
    requirements.txt       Pythonの依存関係
    .gitignore
    .git/                  VBAとPythonの共通Git管理
    .vscode/settings.json  使用するPythonの設定
    Pysource/              Pythonコード
    VBsource/              ブックから出力したVBAソース
    Sandbox/               本番採用前の試作・検証
    ブック名.xlsm          必要に応じて配置（既定でGit対象外）
```

Pythonコードは `Pysource`、VBAソースは `VBsource` に保存します。プロジェクト、README、Git履歴は共通です。

## 作成方法

1. `Workspace.code-workspace` またはワークスペース直下をVS Codeで開きます。
2. 専用拡張のインストールは不要です。以前の「Workspace Project Git」が入っている場合は、拡張機能一覧から「無効にする（ワークスペース）」を選び、必要に応じてウィンドウを再読み込みしてください。同名の旧タスクが重複するのを防ぎます。他のワークスペースで使う拡張はアンインストールする必要はありません。
3. 「ターミナル」→「タスクの実行」→「New: VBA×Pythonプロジェクト新規作成」を選びます。
4. プロジェクト名と、インストール済みPythonのバージョンを入力します。`Sample` なら `Projects/Project Sample` が作成されます。

システムPythonを利用し、仮想環境の作成・パッケージ導入・Excelブック作成はしません。VBAのブックへの取り込みも行いません。Gitは初期化とステージングまで行い、コミットやpushは実行しません。Gitビューへの表示は標準Git拡張機能の自動検出に任せます。表示されない場合は `Developer: Reload Window`、または `Git: リポジトリを開く` で作成先を指定してください。

UserForm操作には、VS Codeタスク `Excel: UserForm情報をCSV出力（アドイン）` と `Excel: 編集したUserForm CSVをExcelへ反映` を使用できます。必要なアドインの準備と対象範囲は [.tools/UserFormCsvExporter/README.md](.tools/UserFormCsvExporter/README.md) を確認してください。出力タスクはExcelでブックを読み取り、反映タスクはバックアップを作成してブックを変更・保存します。実行前に対象ブックと操作範囲を確認してください。

標準タスクと同じ処理を、PowerShellから直接実行することもできます。専用拡張によるGitビューへの明示的な登録は行いません。

```powershell
& .\.tools\New-Project.ps1 -ProjectName "Sample" -PythonVersion 3.13
```

使用できるPythonは `py -0p` で確認できます。通常は親ワークスペースのまま作業し、`Python: Select Interpreter` で使用するPythonを選んでください。子フォルダーの `.vscode/settings.json` は親には適用されません。その設定を使う場合だけ、プロジェクトフォルダーを別ウィンドウで開きます。

作成処理と検証方法の詳細は [.tools/README.md](.tools/README.md)、プロジェクトの開発手順は [Projects/_Template_Combined/README.md](Projects/_Template_Combined/README.md) を参照してください。