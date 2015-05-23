app.controller 'playerCtrl', ($scope, $state, $stateParams, $timeout, $ionicLoading, $ionicPlatform, $vlc) ->
  $scope.player = player = $vlc

  connect = ->
    return if $scope.connecting
    $scope.connecting = { attempts: 0 }

    $ionicLoading.show
      scope            : $scope
      templateUrl      : 'src/player/loading.html'
      hideOnStateChange: true

    attempt = ->
      $scope.connecting.attempts += 1
      player.connect($stateParams.address)
        .then ->
          delete $scope.connecting
          $ionicLoading.hide()

        .catch (err) ->
          $timeout(attempt, 1000)

    attempt()

  leave = ->
    player.disconnect()
    $state.go('connect')

  player.on('disconnected', connect)

  $ionicPlatform.on('pause', -> player.disconnect())
  $ionicPlatform.on('resume', connect)

  $ionicPlatform.onHardwareBackButton(leave)

  connect()
