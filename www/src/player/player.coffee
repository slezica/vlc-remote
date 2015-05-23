app.controller 'playerCtrl', ($scope, $stateParams, $vlc, $timeout, $ionicLoading) ->
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

  player.on('disconnected', connect)
  connect()
