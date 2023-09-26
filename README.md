# AWS IoT Core shadow client in Ruby


## Device

```ruby
irb(main):006:0> require './device.rb'
irb(main):007:0> d = Device.new
irb(main):008:0> d.connect
irb(main):009:0> d.subscribe
irb(main):010:0> d.local_state="normal"
irb(main):011:0> d.report
```

## App

```
Usage: ./app.sh desired <state> OR ./app.sh get
```
