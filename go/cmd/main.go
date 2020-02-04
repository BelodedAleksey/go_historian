package main

import (
	"github.com/go-flutter-desktop/go-flutter"
	"github.com/gonutz/w32"
	"github.com/nanitefactory/winmb"
	"github.com/pkg/errors"
	"image"
	_ "image/png"
	"os"
	"path/filepath"
	"strings"
)

// vmArguments may be set by hover at compile-time
var vmArguments string

func main() {
	// DO NOT EDIT, add options in options.go
	mainOptions := []flutter.Option{
		flutter.OptionVMArguments(strings.Split(vmArguments, ";")),
		flutter.WindowIcon(iconProvider),
	}
	err := flutter.Run(append(options, mainOptions...)...)
	if err != nil {
		winmb.MessageBoxPlain("ИСКЛЮЧЕНИЕ: ", err.Error())
		os.Exit(1)
	}	
}

//hide console windows
func init() {
	console := w32.GetConsoleWindow()
	if console != 0 {
		_, consoleProcID := w32.GetWindowThreadProcessId(console)
		if w32.GetCurrentProcessId() == consoleProcID {
			w32.ShowWindowAsync(console, w32.SW_HIDE)
		}
	}

}

func iconProvider() ([]image.Image, error) {
	execPath, err := os.Executable()
	if err != nil {
		return nil, errors.Wrap(err, "failed to resolve executable path")
	}
	execPath, err = filepath.EvalSymlinks(execPath)
	if err != nil {
		return nil, errors.Wrap(err, "failed to eval symlinks for executable path")
	}
	imgFile, err := os.Open(filepath.Join(filepath.Dir(execPath), "assets", "doge.png"))
	if err != nil {
		return nil, errors.Wrap(err, "failed to open assets/icon.png")
	}
	img, _, err := image.Decode(imgFile)
	if err != nil {
		return nil, errors.Wrap(err, "failed to decode image")
	}
	return []image.Image{img}, nil
}
