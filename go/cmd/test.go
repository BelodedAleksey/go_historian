package main

import (
	"fmt"
	"github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/go-flutter/plugin"
)

var _ flutter.Plugin = &TestPlugin{}
var workPercent chan int

type TestPlugin struct {
	stop   chan bool
	signal chan bool
}

func (p *TestPlugin) InitPlugin(messenger plugin.BinaryMessenger) error {
	channel := plugin.NewMethodChannel(messenger, "test", plugin.StandardMethodCodec{})
	channel.HandleFunc("onTest", p.test)
	channel.HandleFunc("onProgress", p.progress)
	p.stop = make(chan bool)
	p.signal = make(chan bool)
	workPercent = make(chan int)
	eventChannel := plugin.NewEventChannel(messenger, "event", plugin.StandardMethodCodec{})
	eventChannel.Handle(p)
	return nil
}

func (p *TestPlugin) OnListen(arguments interface{}, sink *plugin.EventSink) {
	for {
		select {
		case <-p.stop:
			return
		case perc := <-workPercent:
			fmt.Println("Total percent in onlIsten: ", perc)
			sink.Success(perc)
		default:
		}
	}
}

func (p *TestPlugin) OnCancel(arguments interface{}) {
	p.stop <- true
}

func (p *TestPlugin) progress(args interface{}) (reply interface{}, err error) {
	//queryEnd <- true
	return "", nil

}

func (p *TestPlugin) test(args interface{}) (reply interface{}, err error) {
	inArgs := args.([]interface{})
	server := inArgs[0].(string)
	interval := inArgs[1].(string)
	tags := []string{}
	times := []timePeriod{}
	var iNext, j int
	for i := 2; i < len(inArgs); i++ {
		aStr := inArgs[i].(string)
		if aStr == "\nF\n" {
			iNext = i + 1
			break
		}
		tags = append(tags, aStr)
	}
	for i := iNext; i < len(inArgs); i++ {
		aStr := inArgs[i].(string)
		if aStr == "\nL\n" {
			iNext = i + 1
			break
		}
		times = append(times, timePeriod{aStr, ""})
	}

	for i := iNext; i < len(inArgs); i++ {
		aStr := inArgs[i].(string)
		times[j].end = aStr
		j++
	}
	fetchData(server, tags, times, interval)
	return "OK", nil
}
