extends Node

# signals differ by scenes
# Here we define a speed change signal, which we know will be used in ParallaxBackground
# The debugger might give you a signal is declared but never emitted warning. 
# You may ignore it.

signal speed_change(speed)
