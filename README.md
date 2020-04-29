# README
pundit gemの実験。
https://github.com/varvet/pundit

## 前提
ruby 2.6.3にてテスト

## 実験してみるもの
scaffoldでpostというモデルを作成し、editだけできない状態を作ってみる

## 手順
### 実験用プロジェクトの作成
以下のコマンドでプロジェクト作成
```
rails new .
```

#### scaffoldでpostを操作できる機能を追加
今回は内容はなんでも良いのでtitleのみ
```
rails g scaffold post title:string
```

#### pundit gem追加
Gemfileに以下を追加し、bundle install
```
gem "pundit"
```

### punditを使う前準備

#### 共通のpolicyを生成
共通のpolicyクラスを作成。
policyクラスは認可のルールを記述するクラス。
```
rails g pundit:install
```
app/policies/application_policy.rbが作成される

#### post用のpolicyを作成
```
touch app/policies/post_policy.rb
```
内容は以下のとおり、@userが"user1"の時だけ、editを許可

```
class PostPolicy < ApplicationPolicy
  def edit?
    @user == "user1"
  end
end
```

#### controllerにてpunditを使用できるようにする
controllersの基底クラスであるapplication_controller.rbにincludeする。
また、punditが認可の判定をする時、current_userが呼び出されるので、current_userメソッドを追加。
今回は文字列を返却しているが、本来はログインユーザーのmodelを返却するのが王道。

app/controllers/application_controller.rb
```
class ApplicationController < ActionController::Base
  include Pundit

  def current_user
    "user1" # TODO 本来はここでログインユーザーのモデルを返却する
  end
end
```

### editが許可されているか判定する
#### post controllerに判定処理を追加
app/controllers/posts_controller.rb
```
  # GET /posts/1/edit
  def edit
    authorize @post   <- 追加。authorizeメソッドでeditできるかどうか判定
  end
```

#### エラーハンドリング
以下のようなエラーページを追加。

app/views/errors/error_403.erb
```
<p>Forbidden</p>
```

認可エラーならPundit::NotAuthorizedErrorが飛ぶので、この例外をハンドリングする。
app/controllers/application_controller.rb
```
class ApplicationController < ActionController::Base
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :forbidden        <- 追加

  def current_user
    "user1" # TODO 本来はここがログインユーザーのモデルを返却する
  end

  def forbidden
    render template: 'errors/error_403', status: 403, layout: 'application'  <- 追加
  end
end
```

### 確認
rails sにてサーバを起動して確認。

application_controller.rb#current_user()で返却している文字列とpost_policy.rb#edit?()で判定している文字列が同じなら編集可能。違えばエラーページとなる。
