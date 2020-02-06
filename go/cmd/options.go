package main

import (
	"github.com/go-flutter-desktop/go-flutter"
	file_picker "github.com/miguelpruivo/flutter_file_picker/go"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(1200, 800),
	flutter.WindowDimensionLimits(800, 700, 1800, 800),
	flutter.AddPlugin(&HistPlugin{}),
	flutter.AddPlugin(&file_picker.FilePickerPlugin{}),
}
