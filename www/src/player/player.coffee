app.controller 'playerCtrl', ($scope, $state, $stateParams, $timeout, $ionicLoading, $ionicPlatform, $vlc) ->
  $scope.vlc = $vlc

  connect = ->
    $ionicLoading.show
      scope            : $scope
      templateUrl      : 'src/player/loading.html'
      hideOnStateChange: true

    $vlc.connect($stateParams.address).then ->
      $ionicLoading.hide()

  disconnect = ->
    $ionicLoading.hide()
    $vlc.disconnect()

  $vlc.on('disconnect', connect)

  leave = ->
    disconnect()
    $state.go('connect')

  $ionicPlatform.on('pause', disconnect)
  $ionicPlatform.on('resume', connect)
  $ionicPlatform.onHardwareBackButton ->
    leave()

  if $vlc.connection.status isnt 'connected'
    connect()
