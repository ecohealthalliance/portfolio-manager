#Portfolio Manager

### Setup:

```
sudo ROOT_URL=http://54.83.200.115 mrt -p 80
```

I'll try to explain that command. The ROOT_URL parameter lets meteor know what
addres it is running at so it can generate correct URLs when people call Meteor.absoluteUrl

The mrt command is for meteorite is a package manager for meteor that is needed
to install some of the dependencies.

-p 80 sets the port idependently the ROOT_URL url which can be useful for running
a server behind apache.