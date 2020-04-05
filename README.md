# Folder Queue Manager - FQM
A simple software for adhoc Directory Monitoring, command executing and folder copying/moving software for small tasks

## About

This software is written for adhoc needs of a physics research group [LRG](http://www.lrgresearch.org). With the Covid-19 outbreak, Laboratory went to all remote-work. However, there were some computational codes needed to run on lab computers. However, because of Teamviewer type of remote connection softwares and Reverse SSH were not working on the lab computers, there was a need of this small software. It is best used with Google Drive (GD), Dropbox type of cloud file management tools.

With this code, you can use your GD or Dropbox as a queue for your computation tool. Program checks a folder (likely in GD or Dropbox Folder). When finds a file (likely a Python script), it copies to a temp folder (likely a local folder). Then, it executes the file. When the execution of command finishes, it zips all results and put it to another folder (again likely a GD or Dropbox folder). Therefore, without using any other tools, you can use you Cloud file space as a computation queue. It can be usedbin many computers you need.

We believe, in a days like these, many people may need this kind of software. Therefore, we publish it freely as quick as possible (First release: Mar 25,2020). Code is very primitive. It is easy to recompile for your needs.

## Getting Involved

FQM needs active development. Development of FQM is a volunteer effort, and you can contribute. Please do not hesitate to send your merge requests.

## Features can be added in Future Releases:

- Not delete folders in TEMP folder (it can be good for archiving),
- Change interval of controlling input files,
- Choose output will to be zipped or not be zipped,
- More than one instance,
- Instance(s) will not be work as a child process.

## Maintainer
Sefer Bora Lisesivdin is the original author and the current maintainer of FQM. Please use [his website](http://sblisesivdin.github.io) for contact.

## Licensing
FQM is free software; you can redistribute it and/or modify it under the terms of the GPLv3 as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
