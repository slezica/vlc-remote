app.controller 'connectCtrl', ($scope, $state, $document, $vlc, $ionicLoading, $ionicPlatform) ->
  $scope.form =
    host    : 'ionic-proxy' # '192.168.1.100' #'ionic-proxy'
    port    : 8080
    username: ''
    password: '1'

  $scope.connecting = false

  $scope.connect = ->
    return if $scope.connecting
    $scope.connecting = true

    { host, port, username, password } = $scope.form

    if host is 'ionic-proxy'
      address = "http://#{username}:#{password}@localhost:8100/api"
    else
      address = "http://#{username}:#{password}@#{host}:#{port}"

    $ionicLoading.show
      scope            : $scope
      templateUrl      : 'src/player/loading.html'
      hideOnStateChange: true

    $vlc.connect(address).then ->
      $scope.connecting = false
      $ionicLoading.hide()
      $state.go('player', { address })

  $scope.cancel = ->
    return if not $scope.connecting
    $scope.connecting = false

    $ionicLoading.hide()
    $vlc.disconnect()

  $ionicPlatform.on 'pause', -> $scope.cancel()
  $ionicPlatform.onHardwareBackButton -> $scope.cancel()

  $document.bind 'keyup', (e) ->
    $scope.cancel() if e.keyCode is 27
