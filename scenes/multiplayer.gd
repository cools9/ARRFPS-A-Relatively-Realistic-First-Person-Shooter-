extends Node3D

var ip:="localhost"
var port := 65534
var peer : ENetMultiplayerPeer

func start_server():
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer=peer
	
	
func start_client():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip,port)
	multiplayer.multiplayer_peer=peer
	$MainUi.hide()
