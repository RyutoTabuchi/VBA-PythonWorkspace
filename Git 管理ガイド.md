# Git管理ガイド

Gitは、ファイルの変更履歴を記録し、過去の状態を確認したり、複数人で変更を共有したりするためのツールです。このガイドでは、1つのプロジェクトを1つのGitリポジトリとして管理する基本的な手順を説明します。
## 基本用語

| 用語 | 意味 |
| --- | --- |
| リポジトリ | Gitが変更履歴を管理するプロジェクトの領域 |
| ステージ | 次のコミットに含める変更を選ぶこと |
| コミット | 選んだ変更を履歴として保存すること |
| リモート | GitHubなど、他の場所にある共有用リポジトリ |
| ブランチ | 作業の流れを分けるための履歴上の枝 |
## 初回だけ行う設定

Gitを初めて使うPCでは、コミットに記録する名前とメールアドレスを設定します。次の設定はPC上のすべてのリポジトリに適用されます。
```powershell
git config --global init.defaultBranch main
git config --global user.name "あなたの名前"
```powershell
git config --global --list
```
## 新しいプロジェクトをGitで管理する

### 1. プロジェクトフォルダーを開く
VS Codeで対象のプロジェクトフォルダーを開き、「ターミナル」から新しいターミナルを開きます。Gitコマンドは、必ずプロジェクトのルートフォルダーで実行してください。

```powershell
Get-Location

表示されたパスがプロジェクトの場所と異なる場合は、実際のパスに置き換えて移動します。
```powershell
Set-Location "C:\Users\ユーザー名\Documents\Workspace\プロジェクト名"
```
### 2. `.gitignore`を用意する

`.gitignore`には、Gitで管理しないファイルやフォルダーを記載します。不要なファイルや秘密情報を最初から登録しないよう、最初のコミットより前に用意してください。
### 3. リポジトリを初期化する

プロジェクトフォルダー内で次を実行します。フォルダー内に`.git`が作成され、このプロジェクトの変更履歴を管理できるようになります。
```powershell
git init -b main
```
### 4. 最初のコミットを作成する

まず登録対象を確認します。
```powershell
git status
```
次のコマンドで、`.gitignore`に除外されていない変更をコミット候補として選びます。

```powershell
git add .
ステージされたファイルと差分を確認します。秘密情報や不要なファイルが含まれていないことを確認してください。

```powershell
git status
git diff --cached
```

問題がなければ、履歴に保存します。
```powershell
git commit -m "Initial project setup"
```
コミットメッセージには、その変更で行ったことを短く記載します。日本語でも英語でも構いません。

### 5. GitHubなどのリモートと接続する（必要な場合）
ローカルだけで履歴を管理する場合、この手順は不要です。共有やオンラインバックアップを行う場合は、GitHubなどに空のリポジトリを作成します。ローカルで初期化済みの場合、リモート側にはREADMEや初期コミットを作らず、空の状態にしておくと接続が簡単です。

リモートURLを`<リポジトリURL>`に置き換えて登録します。
```powershell
git remote add origin <リポジトリURL>
git remote -v
`remote -v`で登録先を確認した後、初回のpushを行います。

```powershell
git push -u origin main
`origin`は一般的に使われるリモート名です。`-u`を付けると、以後このブランチの送信先が設定され、通常は`git push`だけで送信できます。

すでにリモートにあるプロジェクトを使う場合は、初期化やリモート登録の代わりにcloneします。
```powershell
git clone <リポジトリURL>
```

## 日常の作業
変更を履歴に保存してリモートと共有する基本の流れです。

1. 作業を始める前に、リモートの変更を取り込みます。
```powershell
git pull
```
2. ファイルを編集した後、変更状態を確認します。

```powershell
git status
```
3. コミットに含める変更を選びます。すべての変更を選ぶ場合は`git add .`、特定のファイルだけを選ぶ場合はファイル名を指定します。

```powershell
git add .
git add Pysource/main.py
```

4. ステージ内容を確認し、コミットします。
```powershell
git diff --cached
git commit -m "変更内容を短く記載"
```
5. リモートに共有します。

```powershell
git push
```

リモートを使わない場合は、`git pull`と`git push`は不要です。`git status`、`git add`、`git commit`でローカルの履歴を管理できます。

## ブランチを使った作業
機能追加や試験的な変更を`main`から分けて作業できます。

```powershell
# ブランチを作成して切り替える
git switch -c feature/add-export
# 現在のブランチを確認する
git branch

# 作業後、mainに戻って変更を取り込む
git switch main
git merge feature/add-export

# 不要になったブランチを削除する
git branch -d feature/add-export
`feature/add-export`は例です。作業内容が分かる名前に置き換えてください。

## よくあるトラブル
### `fatal: not a git repository`と表示される

Gitリポジトリの外でコマンドを実行しています。`Get-Location`で現在地を確認し、プロジェクトフォルダーへ移動してください。新規プロジェクトの場合は、そこで`git init -b main`を実行します。
### 仮想環境などを誤ってGitに登録した

まず`.gitignore`に対象を追加します。すでに追跡中の`.venv`を作業フォルダーから削除せずにGitの追跡だけ解除するには、次を実行します。
```powershell
git rm -r --cached .venv
git add .gitignore
git commit -m "Stop tracking virtual environment"
```

対象が`.venv`以外の場合は、コマンド内のパスを置き換えてください。
### `nothing to commit`と表示される

コミットする新しい変更がない状態です。`git status`で状態を確認してください。変更が未ステージの場合は`git add`で選択してからコミットします。
### ブランチ名を変更する

```powershell
git branch -m old-name new-name
```
例として、現在のブランチ名を`master`から`main`に変更する場合は次のようにします。

```powershell
git branch -m master main
### 直前のコミットメッセージを修正する

```powershell
git commit --amend -m "修正後のメッセージ"
```
すでにリモートへpushしたコミットを書き換えると、他の人の履歴に影響することがあります。共有済みのコミットには、チームで確認せずこの操作を行わないでください。

### HTTPS接続で証明書エラーが発生する
会社や組織のネットワーク、プロキシ、証明書設定が原因の場合があります。組織のGitまたはネットワーク管理者の案内に従って証明書を設定してください。証明書検証を無効にする設定（`http.sslVerify false`）はセキュリティ上危険なため使用しないでください。

## やってはいけないこと
| 操作 | 理由 |
| --- | --- |
| `.env`やパスワード、APIキーをコミットする | 秘密情報が履歴に残り、後から消すのが困難なため |
| 仮想環境（`.venv/`や`venv/`）をコミットする | 環境依存のファイルが大量に含まれるため。必要なパッケージは依存関係ファイルで管理します |
| 内容を確認せず`git add .`してコミットする | 不要なファイルや秘密情報まで登録するおそれがあるため |
| 共有ブランチに対して安易に履歴を書き換える | 他の人の作業やリモートの履歴に影響するため |
## コマンド早見表

| やりたいこと | コマンド |
| --- | --- |
| 状態を確認する | `git status` |
| 変更を選ぶ | `git add .` |
| ステージ内容を確認する | `git diff --cached` |
| 履歴に保存する | `git commit -m "メッセージ"` |
| リモートから取得して統合する | `git pull` |
| リモートへ送信する | `git push` |
| 履歴を確認する | `git log --oneline` |
| ブランチを確認する | `git branch` |
| ブランチを作成して切り替える | `git switch -c ブランチ名` |
| ブランチを切り替える | `git switch ブランチ名` |
