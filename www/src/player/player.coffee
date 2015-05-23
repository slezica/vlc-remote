app.controller 'playerCtrl', ($scope, $stateParams, $vlc) ->
  $vlc.connect($stateParams.address)
  $scope.player = $vlc
