#6/19/2024, 1:04PM, start.
#10/3/2024, 5:59PM, start commenting.
#imports, second one replace with where your StinomXE is.
require 'ruby2d'
require '/home/norvel/Desktop/moreDMaybe/NewXE/StinomsXE/RubyzXE/StinomRubyyXE.rb'
set title: 'X E'
#variables set up.
$draw=StinomDrawXE.new [0.0,500.0,-1000.0],[0.0,0.0,0.0],0,1,2,0,0
$shapes=[]
$position=[50.0,50.0,50.0]
$positions=[]
$velocities=[]
index1=9
#Make positions and velocities.
while (index1 != -1) do
  $positions.push [rand()*200.0-100.0,rand()*200.0-100.0,$position[2]];
  $velocities.push([rand()*8.0-4.0,rand()*8.0-4.0]);
  index1-=1;
end
$part=[]
#Make cube like structure.
#7/2/2024, 10:57AM, start 7/4/2024, 4:11PM, done.
def cube(position,size)
  #Local variable stores current point index starting.
  index=$draw.pointIndex
  $draw.addPoint [position[0]-size/2.0,position[1]-size/2.0,position[2]-size/2.0]
  $draw.addPoint [position[0]+size/2.0,position[1]-size/2.0,position[2]-size/2.0]
  $draw.addPoint [position[0]+size/2.0,position[1]+size/2.0,position[2]-size/2.0]
  $draw.addPoint [position[0]-size/2.0,position[1]+size/2.0,position[2]-size/2.0]
  $draw.addPoint [position[0]-size/2.0,position[1]-size/2.0,position[2]+size/2.0]
  $draw.addPoint [position[0]+size/2.0,position[1]-size/2.0,position[2]+size/2.0]
  $draw.addPoint [position[0]+size/2.0,position[1]+size/2.0,position[2]+size/2.0]
  $draw.addPoint [position[0]-size/2.0,position[1]+size/2.0,position[2]+size/2.0]
  $draw.addShape [index+4,index+5,index+6,index+7]
  #$draw.addShape [index,index+1,index+2,index+3]
  $draw.addShape [index+1,index,index+4,index+5]
  $draw.addShape [index+3,index+2,index+6,index+7]
  #unsure, sure now.
  $draw.addShape [index+1,index+2,index+6,index+5]
  $draw.addShape [index,index+3,index+7,index+4]
  #X E
end
#X E
#Do stuff to view and other things upon key presses.
#6/19/2024, 1:12PM, start.
on :key_down do |event|
  if (event.key == 'up')
    $draw.viewPoint[2]*=2.0
  elsif (event.key == 'down')
    $draw.viewPoint[2]/=2.0
  elsif (event.key == 'w')
    $position[0]+=100.0
  elsif (event.key == 'e')
    $position[0]-=100.0
  elsif (event.key == 's')
    $position[1]+=100.0
  elsif (event.key == 'd')
    $position[1]-=100.0
  end
  #X E
end
#X E
#Some output.
#6/19/2024, 1:13PM, start.
on :mouse_down do |event|
  # x and y coordinates of the mouse button event
  #puts event.x, event.y
  puts "==="
  puts $part
  puts "=="
  puts $draw.drawOrder
  # Read the button event
  case event.button
  when :left
    # Left mouse button pressed down
  when :middle
    # Middle mouse button pressed down
  when :right
    # Right mouse button pressed down
  end
  #X E
end
#X E
#Main draw function
#6/19/2024, 1:21PM, start.
def start()
  #You can uncomment stuff here if you want.
  #Thanks zzzcode.ai
=begin
  $draw.addPoint [rand()*100.0,rand()*100.0,0.0]
  $draw.addPoint [rand()*-100.0,rand()*100.0,10.0]
  $draw.addPoint [rand()*-100.0,rand()*-100.0,10.0]
  $draw.addPoint [rand()*100.0,rand()*-100.0,0.0]
  $draw.addShape [0,1,2,3]
  $draw.addPoint [rand()*100.0,rand()*100.0,0.0]
  $draw.addPoint [rand()*-100.0,rand()*100.0,10.0]
  $draw.addPoint [rand()*-100.0,rand()*-100.0,10.0]
  $draw.addPoint [rand()*100.0,rand()*-100.0,0.0]
  $draw.addShape [4,5,6,7]
=end
  #cube $position, 100.0
  #Set cube positions by velocities and input.
  index=$positions.length-1
  while (index != -1) do
    $positions[index][0]+=$velocities[index][0];
    if ($positions[index][0]<-Window.width/2.0||$positions[index][0]>Window.width/2.0)
      $positions[index][0] = -$positions[index][0]+$velocities[index][0]
    end
    $positions[index][1]+=$velocities[index][1];
    if ($positions[index][1]<-Window.height/2.0||$positions[index][1]>Window.height/2.0)
      $positions[index][1] = -$positions[index][1]+$velocities[index][1]
    end
    cube $positions[index], 100.0
    index-=1;
  end
  #Make lines and points
  #7/26/2024, 1:03PM, start work on points and lines. X E. 1:10PM, like done. X E.
  index=$draw.pointIndex
  while (index != -1)
    if (index==0)
      $draw.addShape [index,$draw.pointIndex-1]
    else
      $draw.addShape [index,index-1]
    end
    $draw.addShape [index]
    index-=1;
  end
  #cube [-$position[0],-$position[1],$position[2]], 100.0
  #Setup
  $draw.set2dPoints
  $draw.setDrawOrder
  $draw.offset [Window.width.to_f()/2.0,Window.height.to_f()/2.0]
  index=$draw.shapeIndex-1
  while (index != -1)
    if ($draw.shapes[$draw.drawOrder[index]].length==1)
      if ($draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]] != nil)
        #Draw point
        $shapes.push Quad.new(x1: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]][0]+5.0,y1: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]][1]+5.0,x2: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]][0]-5.0, y2: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]][1]+5.0,x3: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]][0]-5.0, y3: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]][1]-5.0,x4: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]][0]+5.0,y4: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]][1]-5.0,color: ['#ff0000','#0000ff','#00ff00','#ff00ff','#00ffff','#ffff00','#ffffff'][$draw.drawOrder[index]-($draw.drawOrder[index]/7)*7])
      end
    elsif ($draw.shapes[$draw.drawOrder[index]].length==2)
      #Draw line
      if ($draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]] != nil && $draw.points2d[$draw.shapes[$draw.drawOrder[index]][1]] != nil)
        $shapes.push Line.new(x1: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]][0],y1: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]][1],x2: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][1]][0], y2: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][1]][1],color: ['#ff0000','#0000ff','#00ff00','#ff00ff','#00ffff','#ffff00','#ffffff'][$draw.drawOrder[index]-($draw.drawOrder[index]/7)*7])
      end
    else
      if ($draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]] != nil && $draw.points2d[$draw.shapes[$draw.drawOrder[index]][1]] != nil &&
          $draw.points2d[$draw.shapes[$draw.drawOrder[index]][2]] != nil && $draw.points2d[$draw.shapes[$draw.drawOrder[index]][3]] != nil)
        #Draw quad.
        $shapes.push Quad.new(x1: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]][0],y1: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][0]][1],x2: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][1]][0], y2: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][1]][1],x3: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][2]][0], y3: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][2]][1],x4: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][3]][0],y4: $draw.points2d[$draw.shapes[$draw.drawOrder[index]][3]][1],color: ['#ff0000','#0000ff','#00ff00','#ff00ff','#00ffff','#ffff00','#ffffff'][$draw.drawOrder[index]-($draw.drawOrder[index]/7)*7])
      end
    end
    index-=1
  end
  #X E
end
#X E
set resizable: true
#Done each time an update occurs.
#6/19/2024, 1:22PM, start.
def updater()
  clear
  $shapes=[]
  $draw.reset
  start
  #X E
end
#X E
#Make things happen in Ruby2d.
#6/19/2024, 1:11PM, start.
update do
  updater
  #X E
end
#X E
#Let us start everything.
start
show
#X E
