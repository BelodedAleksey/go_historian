package main

import (
	"fmt"

	"github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/go-flutter/plugin"
	"github.com/nanitefactory/winmb"
)

var _ flutter.Plugin = &HistPlugin{}
var workPercent chan float64

type HistPlugin struct {
	stop chan bool
}

func (p *HistPlugin) InitPlugin(messenger plugin.BinaryMessenger) error {
	channel := plugin.NewMethodChannel(messenger, "hist", plugin.StandardMethodCodec{})
	channel.HandleFunc("onFetch", p.onFetch)
	channel.HandleFunc("onFetchTags", p.onFetchTags)
	channel.HandleFunc("onReadConfig", p.onReadConfig)
	channel.HandleFunc("onSaveConfig", p.onSaveConfig)
	p.stop = make(chan bool)
	workPercent = make(chan float64)
	eventChannel := plugin.NewEventChannel(messenger, "event", plugin.StandardMethodCodec{})
	eventChannel.Handle(p)
	return nil
}

func (p *HistPlugin) OnListen(arguments interface{}, sink *plugin.EventSink) {
	for {
		select {
		case <-p.stop:
			return
		case perc := <-workPercent:
			sink.Success(perc)
		default:
		}
	}
}

func (p *HistPlugin) OnCancel(arguments interface{}) {
	p.stop <- true
}

func (p *HistPlugin) onReadConfig(args interface{}) (reply interface{}, err error) {
	filename := args.(string)
	server, tags, times, interval := readParams(filename)
	out := map[interface{}]interface{}{}
	out["server"] = server
	out["interval"] = interval
	tempTags := []interface{}{}
	for _, t := range tags {
		tempTags = append(tempTags, t)
	}
	out["tags"] = tempTags
	tempTimes := []interface{}{}
	for _, t := range times {
		tempMap := []interface{}{}
		tempMap = append(tempMap, t.start)
		tempMap = append(tempMap, t.end)
		tempTimes = append(tempTimes, tempMap)
	}
	out["times"] = tempTimes
	return out, nil
}

func (p *HistPlugin) onSaveConfig(args interface{}) (reply interface{}, err error) {
	inArgs := args.(map[interface{}]interface{})
	filename := inArgs["filename"].(string)
	server := inArgs["server"].(string)
	interval := inArgs["interval"].(string)
	tags := []string{}
	tempTags := inArgs["tags"]
	for _, t := range tempTags.([]interface{}) {
		tags = append(tags, t.(string))
	}
	times := []timePeriod{}
	tempTimes := inArgs["times"]
	for _, t := range tempTimes.([]interface{}) {
		time := t.([]interface{})
		fTime := time[0].(string)
		lTime := time[1].(string)
		times = append(times, timePeriod{fTime, lTime})
	}
	saveParams(filename, server, tags, times, interval)
	return "OK", nil
}

func (p *HistPlugin) onFetchTags(args interface{}) (reply interface{}, err error) {
	server := args.(string)
	tags := queryTags(server)
	return tags, nil
}

func (p *HistPlugin) onFetch(args interface{}) (reply interface{}, err error) {
	//catch panic
	defer func() {
		if r := recover(); r != nil {
			winmb.MessageBoxPlain("ИСКЛЮЧЕНИЕ: ", fmt.Sprintln(r))
		}
	}()

	inArgs := args.(map[interface{}]interface{})
	server := inArgs["server"].(string)
	interval := inArgs["interval"].(string)
	tags := []string{}
	tempTags := inArgs["tags"]
	for _, t := range tempTags.([]interface{}) {
		tags = append(tags, t.(string))
	}
	times := []timePeriod{}
	tempTimes := inArgs["times"]
	for _, t := range tempTimes.([]interface{}) {
		time := t.([]interface{})
		fTime := time[0].(string)
		lTime := time[1].(string)
		times = append(times, timePeriod{fTime, lTime})
	}
	fetchData(server, tags, times, interval)
	return "OK", nil
}
