package main

import (
	"github.com/go-flutter-desktop/go-flutter"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(1200, 800),
	flutter.AddPlugin(&TestPlugin{}),
}