app.controller 'connectCtrl', ($scope, $state) ->
  $scope.form =
    host    : 'ionic-proxy'
    port    : 8080
    username: ''
    password: '1'

  $scope.connect = ->
    { host, port, username, password } = $scope.form

    if host is 'ionic-proxy'
      address = "http://#{username}:#{password}@localhost:8100/api"
    else
      address = "http://#{username}:#{password}@#{host}:#{port}"

    $state.go('player', { address })
