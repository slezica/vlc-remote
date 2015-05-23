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

  disconnect = ->
    player.disconnect()

  $scope.leave = ->
    $scope.leaving = true
    disconnect()

  # $scope.$on '$destroy', ->
  #   console.log('destroy called')
  #
  # player.on 'disconnected', ->
  #   connect() if not $scope.leaving

  $ionicPlatform.on 'resume', -> connect()
  $ionicPlatform.on 'pause', -> disconnect()
  $ionicPlatform.onHardwareBackButton -> $state.go('connect')

  connect()
