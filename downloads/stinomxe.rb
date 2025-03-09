=begin
8/9/2023, 1:11PM, 1:12PM, start translating from Javascript to Ruby.
By Norvel M. IV, Josiah,
on Ubuntu Touch using uText.
1:13PM, X E.
3:04PM, like done, X E. 3:05PM, X E.
1/2/2024, 12:46PM, like done. Begin compiler tests and fixes. X E.
12:57PM, like done. X E.
3/12/2024, 7:05PM, like done, begin compiler tests. X E. 7:07PM, fixed one thing, --. X E.
3/14/2024, 4:32PM, done. X E.
3/15/2024, 5:52PM, done. X E.
6/19/2024, 1:40PM, start replacing abs. X E. 1:41PM, done. X E.
2:06PM, break. X E. 2:39PM, start work again. 3:26PM, break. X E.
7/11/2024, 1:05PM, done except untested line and point stuff in draw order but syntactically correct.
1:06PM, X E. 7:10PM, fixes, like done. X E.
7/12/2024, 10:26AM, like done, X E.
7/18/2024, 2:54PM, done. X E.
7/19/2024, 6:31PM, like done and tested, used 1.0e-7 pad for setDrawOrder. X E. 6:32PM, X E.
7/23/2024, 1:07PM, done. X E. 6:08PM, done. X E.
7/26/2024, 1:22PM, like done. X E. 3:27PM, like done. X E.
7/30/2024, 2:03PM, like broke. X E. 5:51PM, some fixes near now. X E.
8/1/2024, 4:36PM, like done. X E.
8/2/2024, 5:34PM, like done. X E. 5:38PM, like done. X E. 5:41PM, like done. X E.
5:48PM, like done. X E. 6:03PM, like done. X E. 7:05PM, like done. X E.
7:09PM, like done. X E. 8/8/2024, 8:31PM, like done. X E.
8/9/2024, 8:41PM, like done. 8:41PM, X E.
9:16PM, broken. 9:21PM, like done. X E.
9/24/2024, 7:48PM, like done. X E.
9/27/2024, 1:54PM, 1:55PM, like done and ready to publish. X E.
10/3/2024, 5:32PM, start commenting. 5:58PM, done and did some other stuff. X E.
10/17/2024, 3:33PM, begin fixing minor bugs.
3:34PM, like done. X E. 3:41PM, done. X E.
10/24/2024, 2:55PM, begin fixing.
2:56PM, done. X E.
12/17/2024, 5:43PM, start work. X E.
12/18/2024, 1:41PM, done. X E.
12/24/2024, 11:53AM, done. X E.
1/7/2025, 4:40PM, done. X E.
4:56PM, done. X E.
=end
=begin
/*
8/3/2023, 3:50PM, start translating from Swift to
Javascript.
By Norvel M. IV, Josiah.
On Ubuntu Touch using uText.
3:52PM, X E. 4:41PM, like done, X E.
*/
/*
7/26/2023, 12:32PM, start.
Started by Norvel M. IV, Josiah.
Started on Ubuntu Touch using uText.
I define "X E" and "XE" ending things to mean:
"All that is near and with this me and since like my last adequate uncertainty to this me as per one might be input maybe or might not be input maybe or might be output maybe or might not be output maybe, maybe or maybe not, maybe.".
In a sentence, "A" may be lower case and if a period is after "X E" then period may be omitted from that definition.
This Sinom is intended to allow drawing in 3 or more dimensions using dimension axes on a 2 dimensional screen.
Sinom is like just math for this.
SinomMathXE contains static functions like for math.
SinomDrawXE should be an interface to do math for drawing on a 2 dimensional screen using 3 or more dimensions.
12:41PM, X E.
6:19PM, like done, X E.
8/1/2023, 10:45AM, like done, X E. 11:01AM, like done, X E.
11:07AM, like done, X E. 11:10AM, like done,  X E.
11:15AM, like done, X E. 6:01PM, like done, X E.
6:17PM, like done, X E.
*/
#7/26/2023, 12:41PM, start adding import. 12:42PM, done.
#import Darwin
#7/26/2023, 12:42PM, start. 2:48PM, done, X E.
=end
#This is mainly a utility class for functions.
class StinomMathXE
  #getDistance, point and otherPoint are constants to get distance between, others are dynamic and for reuse
  #8/3/2023, 3:52PM, done to this. 3:56PM, fix in getDistance.
  #7/26/2023, 12:43PM, start. 12:50PM, done.
  def self.getDistance(point, otherPoint, index=0, distance=0.0)
    index=point.length-1;
    distance=0.0;
    while (index != -1) do
      distance+=(point[index]-otherPoint[index])*(point[index]-otherPoint[index]);
      index-=1;
      #8/9/2023, 1:34PM, fix.
    end
    #X E
    return Math.sqrt(distance);
    #X E
  end
  #X E
  #This function returns whether things are like equal with conditions like rounding or in range.
  #8/9/2023, 1:23PM, done getDistance.
  ##8/3/2023, 3:54PM, done getDistance.
  ##7/26/2023, 12:51PM, start. 1:01PM, done.
  def self.precisionEquals?(number, compareTo, roundWith=1.0, shouldRound=false, precPad=0.0)
    #Checks, if it can then return true but false if all fails.
    if (number==compareTo)
      #X E
      return true;
      #X E
    elsif (shouldRound)
      #7/23/2024, 12:56PM, start fix. 12:57PM, done. 1:00PM, continued. done. X E.
      #1:07PM, better all now. X E.
      if ((number*roundWith).round().to_f()/roundWith==
        (compareTo*roundWith).round().to_f()/roundWith)
        #X E
        return true;
        #X E
      elsif ((number*roundWith).round().to_f()/roundWith==compareTo)
        #X E
        return true;
        #X E
      end
    end
    if (precPad != 0.0)
      #X E
      return (compareTo >= number-precPad && compareTo <= number+precPad) || (number >= compareTo-precPad && number <= compareTo+precPad);
      #X E
    end
    #X E
    return false;
    #X E.
  end
  #X E
  #This function takes all but last 2 as constants and uses last 2 as dynamic for reusage.
  #It takes a 3d+ point and puts it in 2d on view plane.
  #8/9/2023, 1:31PM, done precisionEquals?.
  #8/3/2023, 3:56PM, done precisionEquals.
  #7/26/2023, 1:01PM, 1:02PM, start. 1:31PM, done, X E. 1:36PM, fix. 5:08PM, fix.
  def self.to2dPoint(point, viewPoint, viewAtPoint, 
    xDimen=0, yDimen=1, zDimen=2, roundWith=1.0, shouldRound=false,precPad=0.0, 
    index=0, otherPoint=Array.new(point.length,0.0))
    #8/1/2023, 10:44AM, 10:45AM, fixes.
    #6/19/2024, 1:46PM, start fixes. 2;39PM, resume work.
    #x=x0+(x1-x0)t
    #finding t: (x-x0)/(x1-x0)=t
    if ((viewAtPoint[zDimen]-viewPoint[zDimen]).abs()>(point[zDimen]-viewPoint[zDimen]).abs())
      #Too close, X E.
      return nil;
      #X E
    elsif ((viewAtPoint[zDimen]-viewPoint[zDimen] >= -0.0) != (point[zDimen]-viewPoint[zDimen] >= -0.0))
      #Wrong way, X E.
      return nil;
      #X E
    end
    #Get point in view plane.
    index=point.length-1;
    if (index==zDimen)
      index-=1;
    end
    #7/2/2024, 10:52AM, start work. 11:23AM, done.
    #x=x0+(ex-x0)*t
    #find t?
    #we have a second x, viewAtPoint, use it.
    #(x-x0)/(ex-x0)=t
    while (index != -1)
      otherPoint[index]=viewPoint[index]+(point[index]-viewPoint[index])*(viewAtPoint[zDimen]-viewPoint[zDimen])/(point[zDimen]-viewPoint[zDimen]);
      index-=1;
      if (index==zDimen)
        index-=1;
      end
    end
    #Check for in view plane.
    index = otherPoint.length-1;
    while ((index==xDimen||index==yDimen||index==zDimen)&&index != -1)
      index-=1
    end
    while (index != -1) do
      if (!StinomMathXE.precisionEquals?(otherPoint[index],viewAtPoint[index],roundWith,shouldRound,precPad))
        #Not to view plane, X E.
        return nil;
        #X E
      end
      index-=1;
      while ((index==xDimen||index==yDimen||index==zDimen)&&index != -1)
        index-=1;
      end
    end
    #To view plane, return x and y, X E.
    return [otherPoint[xDimen]-viewAtPoint[xDimen], otherPoint[yDimen]-viewAtPoint[yDimen]];
    #X E
  end
  #X E
  #Return if two points are exactly same. All but last are constant inputs and last is dynamic for reuse.
  #8/15/2024, 6:12PM, start. 6:17PM, like done. 6:19PM, like done with fix. 12/17/2024, 6:07PM, start revamp.
  #6:08PM, done. X E.
  def self.pointsEqual?(point1,point2,indexer=Array.new(1,0))
    #iterate and if any not equal, false.
    indexer[0]=point1.length-1;
    while (indexer[0] != -1) do
      if (point1[indexer[0]] != point2[indexer[0]])
        #X E
        return false;
        #X E
      end
      indexer[0]-=1;
    end
    #X E
    return true;
    #X E
  end
  #X E
  #For from start to stop in indices of points with all else dynamic for reuse, is index in infinitely stretching line?
  #8/15/2024, 6:18PM, start. 6:40PM, like done. 12/17/2024, 6:14PM, done revamp.
  def self.inLine?(pointStart,pointEnd,point,indexer=Array.new(2,0),numbers=Array.new(1,0.0))
    #Get a travel dimension.
    indexer[0]=point.length-1;
    while (indexer[0] != -1) do
      if (pointStart[indexer[0]] != pointEnd[indexer[0]])
        break;
      end
      indexer[0]-=1;
    end
    if (indexer[0] == -1)
      #X E
      return true;
      #X E
    end
    #Compare all other dimension travels.
    indexer[1]=point.length-1;
    numbers[0]=0.0;
    while (indexer[1] != -1) do
      if (pointStart[indexer[1]] != point[indexer[1]])
        if (indexer[1] != indexer[0])
          if (numbers[0]==0.0)
            if (((pointEnd[indexer[1]]-pointStart[indexer[1]])/(pointEnd[indexer[0]]-pointStart[indexer[0]])).abs() !=
            ((point[indexer[1]]-pointStart[indexer[1]])/(point[indexer[0]]-pointStart[indexer[0]])).abs())
              #X E
              return false;
              #X E
            elsif ((pointEnd[indexer[1]]-pointStart[indexer[1]])/(pointEnd[indexer[0]]-pointStart[indexer[0]]) ==
            (point[indexer[1]]-pointStart[indexer[1]])/(point[indexer[0]]-pointStart[indexer[0]]))
              numbers[0]=1.0;
            else
              numbers[0] = -1.0;
            end
          elsif ((pointEnd[indexer[1]]-pointStart[indexer[1]])/(pointEnd[indexer[0]]-pointStart[indexer[0]]) !=
          (point[indexer[1]]-pointStart[indexer[1]])/(point[indexer[0]]-pointStart[indexer[0]])*numbers[0])
            #X E
            return false;
            #X E
          end
        end
      elsif (indexer[1]==indexer[0])
        #X E
        return false;
        #X E
      elsif (indexer[1] != indexer[0])
        if (pointStart[indexer[1]] != pointEnd[indexer[1]])
          #X E
          return false;
          #X E
        end
      end
      indexer[1]-=1;
    end
    #X E
    return true;
    #X E
  end
  #X E
  #Return average of all distances from a line (p1,p2) to a point, pf.
  #12/17/2024, 5:46PM, start. 6:00PM, done. X E. 6:02PM, done. X E.
  def self.lineDistanceTo(p1,p2,pf,numbers=[0.0,0.0,0.0],index=0)
    index=p1.length-1;
    numbers[0]=0.0;
    numbers[1]=0.0;
    numbers[2]=0.0;
    while (index != -1) do
      numbers[0]+=(p1[index]-pf[index])*(p1[index]-pf[index]);
      numbers[1]+=2.0*(p1[index]-pf[index])*(p2[index]-p1[index]);
      numbers[2]+=(p2[index]-p1[index])*(p2[index]-p1[index]);
      index-=1;
    end
    if (numbers[2]==0.0)
      if (numbers[1]==0)
        #X E
        return Math.sqrt(numbers[0]);
        #X E
      end
      #X E
      return (2.0*((numbers[0] + numbers[1])**(3.0/2.0)))/(3.0*numbers[1])-(2.0*((numbers[0])**(3.0/2.0)))/(3.0*numbers[1]);
      #X E
    end
    #X E
    return (((numbers[1] + 2.0*numbers[2])*Math.sqrt(numbers[0] + numbers[1] + numbers[2]))/(4.0*numbers[2]) - ((numbers[1]*numbers[1] - 4.0*numbers[0]*numbers[2])*Math.log(numbers[1] + 2.0*numbers[2] + 2.0*Math.sqrt(numbers[2])*Math.sqrt(numbers[0] + numbers[1] + numbers[2])))/(8.0*(numbers[2]**(3.0/2.0))))-((numbers[1]*Math.sqrt(numbers[0]))/(4.0*numbers[2]) - ((numbers[1]*numbers[1] - 4.0*numbers[0]*numbers[2])*Math.log(numbers[1] + 2.0*Math.sqrt(numbers[2])*Math.sqrt(numbers[0])))/(8.0*(numbers[2]**(3.0/2.0))));
    #X E
  end
  #X E
  #This returns whether shape of indices draws before shape of otherIndices. After Dimen's is for reuse.
  #8/9/2023, 1:40PM, done to2dPoint.
  #8/3/2023, 4:01PM, done to2dPoint. 4:01PM, break. 4:04PM, back.
  #7/26/2023, 2:02PM, start. 2:47PM, 2:48PM, done. 3/12/2024, 5:40PM, start translating from JS to Ruby. 6:52PM, done.
  def self.shouldDrawBefore?(viewPoint, points, points2d, indices, otherIndices,indexer=Array.new(5,0),numbers=Array.new(18,0.0),vector=Array.new(viewPoint.length,0.0))
    #First a non-point check. 8/1/2023, 11:00AM, fix. 3/6/2024, 2:30PM, fixed something.
    indexer[0]=otherIndices.length-1;
    while (indexer[0] != -1) do
      if (points2d[otherIndices[indexer[0]]]==nil)
        #X E
        return true;
        #X E
      end
      indexer[0]-=1;
    end
    indexer[0]=indices.length-1;
    while (indexer[0] != -1) do
      if (points2d[indices[indexer[0]]]==nil)
        #X E
        return false;
        #X E
      end
      indexer[0]-=1;
    end
    #7/2/2024, 11:53AM, tried stuff recently, need full revamp. 11:55PM, start work. 12:07PM, mostly working but clearly not.
    #12:08PM, Now it works by find points in rect of other and project to other those. I should get area that is in both and
    #compare. Good way, get rects of each and what is in both rects compare. How to get that common rect? Max of mins and
    #min of maxes of rects, then project back to shapes. If max is less than min then no intersect. 12:14PM, X E. 5:23PM,
    #Took break at last time, back. 5:24PM. 6:13PM, TODO fix for parallel. 6:21PM, break. 7/4/2024, 9:09AM start work.
    #2:14PM, start work again, break was near 11:00AM. 4:24PM, break. 5:12PM, back. 8:32PM, mathematically sound, not working.
    #8:32PM, break. 7/5/2024, 10:13AM, recently started. 1:43PM, break. 2:31PM, back.
    #7/6/2024, 1:53PM, start work. 3:45PM, back. 3:59PM, break. 4:34PM, back. 7:18PM, sort of works. 7:18PM, X E.
    #7/9/2024, 11:04AM, start work., 1:28PM, break, broken. 5:29PM, back. 6:52PM, added "pad" and it works now.
    #Now just points and lines and like them. 6:54PM, break. 6/10/2024, 12:13PM, back. 12:30PM, made point like
    #compare for like 3+ point shapes. 12:34PM, break. 7/11/2024, 11:24AM, back. 11:53AM, done line like in planar.
    #12:44PM, 2 lines like done. Now just one line only adding z. 1:05PM, like done. X E. 7:07PM, back to fix some.
    #7:09PM, like done. X E. 7/12/2024, 10:09AM, started work recently. 10:24AM, like done. 10:26AM, done tested.
    #7/18/2024, 2:27PM, start work. 2:54PM, like done. X E. 7/19/2024, 3:23PM, start work. 3:31PM, fail. X E.
    #3:35PM, fix but still fail. X E. 4:24PM, back. 4:33PM, sort of but not working. X E. 5:56PM, start work.
    #6:17PM, done. 7/30/2024, 5:55PM, started work. 7:14PM, still broke. X E. 8/1/2024, 3:07PM, start work.
    #3:08PM, like done. X E. 3:51PM, still working. 4:35PM, still inaccurate somehow but worked around. 4:36PM, X E.
    #8/2/2024, 5:00PM, start work. 5:33PM, like done. X E. 8/6/2024, 5:12PM, like done, started 5:00PM.
    #6:07PM, broke. X E. 6:14PM, break. 9:06PM, looked over and some changes near now. 9:07PM, X E.
    #8/7/2024, 9:16AM, start work. 10:15AM, can't fix. 10:15AM, X E. 12:39PM, started again.
    #1:26PM, break. X E. 1:29PM, stayed working to now. Break. 7:15PM, started. 7:50PM, break.
    #8/8/2024, 12:55PM, back, working. 1:39PM, break, broken. 5:47PM, started. 8:31PM, like done. X E.
    #8:39PM, still working. 8:49PM, break, broken. 8/9/2024, 11:29AM, working. 12:48PM, break, broken.
    #2:42PM, back. 3:02PM, busted. break. 3:03PM, X E. 6:27PM, begin work. 8:40PM, like done. X E.
    #9:14PM, still working. 9:16PM, still broken. 8/15/2024, 5:11PM, back to work. 7:59PM, break.
    #9/13/2024, 11:16AM, start work. 2:00PM, break. 5:56PM, working again. 7:08PM, break. X E.
    #7:18PM, back. 8:01PM, break. X E. 9/18/2024, 4:38PM, start work. 7:31PM, break.
    #9/20/2024, 4:36PM, start work. 7:44PM, z does not work. break. X E.
    #9/24/2024, 7:02PM, back. 7:38PM, like done. X E. 7:44PM, StinomXE done. X E.
    #9/27/2024, 11:26AM, started work. 1:53PM, like done. X E.
    #12/17/2024, 6:04PM, start work. 7:02PM, maybe done. 9:16PM, like end, broken.
    #12/18/2024, 12:39PM, begin work. 1:41PM, done.
    #First check for empty, then find intersects of views and compare corresponding shapes.
    if (otherIndices.length==0)
      #X E
      return true;
      #X E
    elsif (indices.length==0)
      #X E
      return false;
      #X E
    end
    #default
    #https://mathworld.wolfram.com/PolygonCentroid.html
    #https://mathworld.wolfram.com/PolygonArea.html
    #indices
    #Get centroid point of shapes.
    #check for need a complex centroid equation
    if (indices.length>2)
      indexer[2]=indices.length-1;
      #Get if all equal
      while (indexer[2] != 0) do
        if (!StinomMathXE.pointsEqual?(points[indices[0]],points[indices[indexer[2]]],indexer))
          break;
        end
        indexer[2]-=1;
      end
      if (indexer[2] != 0)
        #Get if all collinear.
        indexer[3]=indexer[2]-1;
        while (indexer[3] != 0) do
          if (!StinomMathXE.inLine?(points[indices[0]],points[indices[indexer[2]]],points[indices[indexer[3]]],indexer,numbers))
            break;
          end
          indexer[3]-=1;
        end
        if (indexer[3] != 0)
          #Finally we have a planar shape.
          #Get x and y in 2d on plane using law of cosines and sine relation to a cosine.
          #Y needs to be arbitrarily set.
          #https://www.mathsisfun.com/algebra/trig-solving-sss-triangles.html
          #(a*a+b*b-c*c)/(2ab)=cos(C)
          #a
          numbers[5]=StinomMathXE.getDistance(points[indices[0]],points[indices[indexer[2]]],indexer[0],numbers[0]);
          indexer[4]=viewPoint.length;
          numbers[14]=0.0;
          numbers[15]=0.0;
          numbers[16]=0.0;
          numbers[3]=0.0;
          numbers[17]=0.0;
          indexer[3]=indexer[2];
          while (indexer[3] != -1) do
            if (indexer[3]==0)
              #x and y are 0.
              numbers[8]=0.0;
              numbers[9]=0.0;
            elsif (indexer[3]==indexer[2])
              #defined indexer[3] axis as x.
              numbers[8]=numbers[5];
              numbers[9]=0.0;
            else
              #c
              numbers[6]=StinomMathXE.getDistance(points[indices[indexer[2]]],points[indices[indexer[3]]],indexer[0],numbers[0]);
              #b
              numbers[7]=StinomMathXE.getDistance(points[indices[0]],points[indices[indexer[3]]],indexer[0],numbers[0]);
              #cos(C) or x.
              numbers[8]=(numbers[5]*numbers[5]+numbers[7]*numbers[7]-numbers[6]*numbers[6])/(2.0*numbers[5]*numbers[7])*numbers[7];
              #sin(C) or y.
              numbers[9]=Math.sqrt(numbers[7]*numbers[7]-numbers[8]*numbers[8]);
              #Get y sign.
              if (numbers[9] != 0.0 && numbers[9] != -0.0)
                if (indexer[4]==viewPoint.length)
                  #get vector more dimensional,
                  indexer[4]=viewPoint.length-1;
                  while (indexer[4] != -1) do
                    vector[indexer[4]]=points[indices[indexer[3]]][indexer[4]]-(points[indices[0]][indexer[4]]+numbers[8]*(points[indices[indexer[2]]][indexer[4]]-points[indices[0]][indexer[4]])/numbers[5]);
                    indexer[4]-=1;
                  end
                  numbers[0]=0.0;
                  indexer[4]=viewPoint.length-1;
                  while (indexer[4] != -1) do
                    numbers[0]+=vector[indexer[4]]*vector[indexer[4]];
                    indexer[4]-=1;
                  end
                  numbers[0]=Math.sqrt(numbers[0]);
                  indexer[4]=viewPoint.length-1;
                  while (indexer[4] != -1) do
                    vector[indexer[4]]/=numbers[0];
                    indexer[4]-=1;
                  end
                  #get index to check
                  indexer[4]=viewPoint.length-1;
                  indexer[1]=viewPoint.length-2;
                  while (indexer[1] != -1) do
                    if (vector[indexer[1]].abs()>vector[indexer[4]].abs())
                      indexer[4]=indexer[1];
                    end
                    indexer[1]-=1;
                  end
                  #Reverse if needed
                  if (vector[indexer[4]] < -0.0)
                    numbers[9] = -numbers[9];
                    indexer[0]=vector.length-1;
                    while (indexer[0] != -1) do
                      vector[indexer[0]] *= -1.0;
                      indexer[0]-=1;
                    end
                  end
                else
                  #Just check index.
                  numbers[0]=points[indices[indexer[3]]][indexer[4]]-(points[indices[0]][indexer[4]]+numbers[8]*(points[indices[indexer[2]]][indexer[4]]-points[indices[0]][indexer[4]])/numbers[5]);
                  if (numbers[0] != 0.0 && numbers[0] != -0.0)
                    if (numbers[0] < -0.0)
                      numbers[9] = -numbers[9];
                    end
                  end
                end
              else
                indexer[3]=1;
              end
            end
            #Sum that for average of all distances.
            #numbers[8] is x and numbers[9] is y.
            if (indexer[3]==indexer[2])
              numbers[10]=numbers[8];
              numbers[11]=numbers[9];
              numbers[12]=numbers[8];
              numbers[13]=numbers[9];
            else
              #use numbers 10 and 11 here from last time before setting them.
              #area
              numbers[14]+=numbers[8]*numbers[11]-numbers[10]*numbers[9];
              #x, y
              numbers[15]+=(numbers[8]+numbers[10])*(numbers[8]*numbers[11]-numbers[10]*numbers[9]);
              numbers[16]+=(numbers[9]+numbers[11])*(numbers[8]*numbers[11]-numbers[10]*numbers[9]);
              #Average line distance.
              numbers[7]=StinomMathXE.getDistance(points[indices[indexer[3]]],points[indices[indexer[3]+1]],indexer[0],numbers[0]);
              numbers[17]+=numbers[7];
              numbers[3]+=StinomMathXE.lineDistanceTo(points[indices[indexer[3]]],points[indices[indexer[3]+1]],viewPoint,numbers,indexer[0])*numbers[7];
              if (indexer[3]==0)
                #use last and current
                numbers[14]+=numbers[12]*numbers[9]-numbers[8]*numbers[13];
                #x, y
                numbers[15]+=(numbers[12]+numbers[8])*(numbers[12]*numbers[9]-numbers[8]*numbers[13]);
                numbers[16]+=(numbers[13]+numbers[9])*(numbers[12]*numbers[9]-numbers[8]*numbers[13]);
                numbers[7]=StinomMathXE.getDistance(points[indices[0]],points[indices[indexer[2]]],indexer[0],numbers[0]);
                numbers[17]+=numbers[7];
                numbers[3]+=StinomMathXE.lineDistanceTo(points[indices[0]],points[indices[indexer[2]]],viewPoint,numbers,indexer[0])*numbers[7];
              else
                numbers[10]=numbers[8];
                numbers[11]=numbers[9];
              end
            end
            indexer[3]-=1;
          end
          #Get average distance of all
          numbers[3]/=numbers[17];
          #Get distance of centroid.
          numbers[15]/=3.0*numbers[14];
          numbers[16]/=3.0*numbers[14];
          numbers[17]=0.0;
          indexer[1]=viewPoint.length-1;
          while (indexer[1] != -1) do
            numbers[17]+=((points[indices[0]][indexer[1]]+
            (points[indices[indexer[2]]][indexer[1]]-points[indices[0]][indexer[1]])/numbers[5]*numbers[15]+
            vector[indexer[1]]*numbers[16])-viewPoint[indexer[1]])**2.0;
            indexer[1]-=1;
          end
          numbers[3]=(numbers[3]+Math.sqrt(numbers[17]))/2.0;
        end
      end
    end
    #distance with 2 point line
    if (indices.length==2)
      numbers[3]=StinomMathXE.lineDistanceTo(points[indices[0]],points[indices[1]],viewPoint,numbers,indexer[0]);
      #Get distance of a point.
    elsif (indices.length != 1&&indexer[3]==0)
      #distance with multi-point line. Start with indexer[2].
      indexer[3]=indexer[2];
      indexer[2]=viewPoint.length-1;
      while (indexer[2] != -1) do
        if (points[indices[0]][indexer[2]] != points[indices[indexer[3]]][indexer[2]])
          indexer[1]=indexer[3];
          indexer[4]=indexer[3];
          while (indexer[1] != -1) do
            if (points[indices[indexer[1]]][indexer[2]]>points[indices[indexer[3]]][indexer[2]])
              indexer[3]=indexer[1];
            end
            if (points[indices[indexer[1]]][indexer[2]]<points[indices[indexer[4]]][indexer[2]])
              indexer[4]=indexer[1];
            end
            indexer[1]-=1;
          end
          break;
        end
        indexer[2]-=1;
      end
      #Get distance based on ends.
      numbers[3]=StinomMathXE.lineDistanceTo(points[indices[indexer[3]]],points[indices[indexer[4]]],viewPoint,numbers,indexer[0]);
    elsif (indices.length==1||indexer[2]==0)
      #Get distance.
      numbers[3]=StinomMathXE.getDistance(viewPoint,points[indices[0]],indexer[0],numbers[0]);
    end
    #other indices
    #Get centroid point of shapes.
    #check for need a complex centroid equation
    if (otherIndices.length>2)
      indexer[2]=otherIndices.length-1;
      #Get if all equal
      while (indexer[2] != 0) do
        if (!StinomMathXE.pointsEqual?(points[otherIndices[0]],points[otherIndices[indexer[2]]],indexer))
          break;
        end
        indexer[2]-=1;
      end
      if (indexer[2] != 0)
        #Get if all collinear.
        indexer[3]=indexer[2]-1;
        while (indexer[3] != 0) do
          if (!StinomMathXE.inLine?(points[otherIndices[0]],points[otherIndices[indexer[2]]],points[otherIndices[indexer[3]]],indexer,numbers))
            break;
          end
          indexer[3]-=1;
        end
        if (indexer[3] != 0)
          #Finally we have a planar shape.
          #Get x and y in 2d on plane using law of cosines and sine relation to a cosine.
          #Y needs to be arbitrarily set.
          #https://www.mathsisfun.com/algebra/trig-solving-sss-triangles.html
          #(a*a+b*b-c*c)/(2ab)=cos(C)
          #a
          numbers[5]=StinomMathXE.getDistance(points[otherIndices[0]],points[otherIndices[indexer[2]]],indexer[0],numbers[0]);
          indexer[4]=viewPoint.length;
          numbers[14]=0.0;
          numbers[15]=0.0;
          numbers[16]=0.0;
          numbers[4]=0.0;
          numbers[17]=0.0;
          indexer[3]=indexer[2];
          while (indexer[3] != -1) do
            if (indexer[3]==0)
              #x and y are 0.
              numbers[8]=0.0;
              numbers[9]=0.0;
            elsif (indexer[3]==indexer[2])
              #defined indexer[3] axis as x.
              numbers[8]=numbers[5];
              numbers[9]=0.0;
            else
              #c
              numbers[6]=StinomMathXE.getDistance(points[otherIndices[indexer[2]]],points[otherIndices[indexer[3]]],indexer[0],numbers[0]);
              #b
              numbers[7]=StinomMathXE.getDistance(points[otherIndices[0]],points[otherIndices[indexer[3]]],indexer[0],numbers[0]);
              #cos(C) or x.
              numbers[8]=(numbers[5]*numbers[5]+numbers[7]*numbers[7]-numbers[6]*numbers[6])/(2.0*numbers[5]*numbers[7])*numbers[7];
              #sin(C) or y.
              numbers[9]=Math.sqrt(numbers[7]*numbers[7]-numbers[8]*numbers[8]);
              #Get y sign.
              if (numbers[9] != 0.0 && numbers[9] != -0.0)
                if (indexer[4]==viewPoint.length)
                  #get vector more dimensional,
                  indexer[4]=viewPoint.length-1;
                  while (indexer[4] != -1) do
                    vector[indexer[4]]=points[otherIndices[indexer[3]]][indexer[4]]-(points[otherIndices[0]][indexer[4]]+numbers[8]*(points[otherIndices[indexer[2]]][indexer[4]]-points[otherIndices[0]][indexer[4]])/numbers[5]);
                    indexer[4]-=1;
                  end
                  numbers[0]=0.0;
                  indexer[4]=viewPoint.length-1;
                  while (indexer[4] != -1) do
                    numbers[0]+=vector[indexer[4]]*vector[indexer[4]];
                    indexer[4]-=1;
                  end
                  numbers[0]=Math.sqrt(numbers[0]);
                  indexer[4]=viewPoint.length-1;
                  while (indexer[4] != -1) do
                    vector[indexer[4]]/=numbers[0];
                    indexer[4]-=1;
                  end
                  #get index to check
                  indexer[4]=viewPoint.length-1;
                  indexer[1]=viewPoint.length-2;
                  while (indexer[1] != -1) do
                    if (vector[indexer[1]].abs()>vector[indexer[4]].abs())
                      indexer[4]=indexer[1];
                    end
                    indexer[1]-=1;
                  end
                  #Reverse if needed
                  if (vector[indexer[4]] < -0.0)
                    numbers[9] = -numbers[9];
                    indexer[0]=vector.length-1;
                    while (indexer[0] != -1) do
                      vector[indexer[0]] *= -1.0;
                      indexer[0]-=1;
                    end
                  end
                else
                  #Just check index.
                  numbers[0]=points[otherIndices[indexer[3]]][indexer[4]]-(points[otherIndices[0]][indexer[4]]+numbers[8]*(points[otherIndices[indexer[2]]][indexer[4]]-points[otherIndices[0]][indexer[4]])/numbers[5]);
                  if (numbers[0] != 0.0 && numbers[0] != -0.0)
                    if (numbers[0] < -0.0)
                      numbers[9] = -numbers[9];
                    end
                  end
                end
              end
            end
            #Sum that for average of all distances.
            #numbers[8] is x and numbers[9] is y.
            if (indexer[3]==indexer[2])
              numbers[10]=numbers[8];
              numbers[11]=numbers[9];
              numbers[12]=numbers[8];
              numbers[13]=numbers[9];
            else
              #use numbers 10 and 11 here from last time before setting them.
              #area
              numbers[14]+=numbers[8]*numbers[11]-numbers[10]*numbers[9];
              #x, y
              numbers[15]+=(numbers[8]+numbers[10])*(numbers[8]*numbers[11]-numbers[10]*numbers[9]);
              numbers[16]+=(numbers[9]+numbers[11])*(numbers[8]*numbers[11]-numbers[10]*numbers[9]);
              #Average line distance.
              numbers[7]=StinomMathXE.getDistance(points[otherIndices[indexer[3]]],points[otherIndices[indexer[3]+1]],indexer[0],numbers[0]);
              numbers[17]+=numbers[7];
              numbers[4]+=StinomMathXE.lineDistanceTo(points[otherIndices[indexer[3]]],points[otherIndices[indexer[3]+1]],viewPoint,numbers,indexer[0])*numbers[7];
              if (indexer[3]==0)
                #use last and current
                numbers[14]+=numbers[12]*numbers[9]-numbers[8]*numbers[13];
                #x, y
                numbers[15]+=(numbers[12]+numbers[8])*(numbers[12]*numbers[9]-numbers[8]*numbers[13]);
                numbers[16]+=(numbers[13]+numbers[9])*(numbers[12]*numbers[9]-numbers[8]*numbers[13]);
                numbers[7]=StinomMathXE.getDistance(points[otherIndices[0]],points[otherIndices[indexer[2]]],indexer[0],numbers[0]);
                numbers[17]+=numbers[7];
                numbers[4]+=StinomMathXE.lineDistanceTo(points[otherIndices[0]],points[otherIndices[indexer[2]]],viewPoint,numbers,indexer[0])*numbers[7];
              else
                numbers[10]=numbers[8];
                numbers[11]=numbers[9];
              end
            end
            indexer[3]-=1;
          end
          #Get average distance of all
          numbers[4]/=numbers[17];
          #Get distance of centroid.
          numbers[15]/=3.0*numbers[14];
          numbers[16]/=3.0*numbers[14];
          numbers[17]=0.0;
          indexer[1]=viewPoint.length-1;
          while (indexer[1] != -1) do
            numbers[17]+=((points[otherIndices[0]][indexer[1]]+
            (points[otherIndices[indexer[2]]][indexer[1]]-points[otherIndices[0]][indexer[1]])/numbers[5]*numbers[15]+
            vector[indexer[1]]*numbers[16])-viewPoint[indexer[1]])**2.0;
            indexer[1]-=1;
          end
          numbers[4]=(numbers[4]+Math.sqrt(numbers[17]))/2.0;
        end
      else
        indexer[3]=1;
      end
    end
    #distance with 2 point line
    if (otherIndices.length==2)
      numbers[4]=StinomMathXE.lineDistanceTo(points[otherIndices[0]],points[otherIndices[1]],viewPoint,numbers,indexer[0]);
      #Get distance of a point.
    elsif (otherIndices.length != 1&&indexer[3]==0)
      #distance with multi-point line. Start with indexer[2].
      indexer[3]=indexer[2];
      indexer[2]=viewPoint.length-1;
      while (indexer[2] != -1) do
        if (points[otherIndices[0]][indexer[2]] != points[otherIndices[indexer[3]]][indexer[2]])
          indexer[1]=indexer[3];
          indexer[4]=indexer[3];
          while (indexer[1] != -1) do
            if (points[otherIndices[indexer[1]]][indexer[2]]>points[otherIndices[indexer[3]]][indexer[2]])
              indexer[3]=indexer[1];
            end
            if (points[otherIndices[indexer[1]]][indexer[2]]<points[otherIndices[indexer[4]]][indexer[2]])
              indexer[4]=indexer[1];
            end
            indexer[1]-=1;
          end
          break;
        end
        indexer[2]-=1;
      end
      #Get distance based on ends.
      numbers[4]=StinomMathXE.lineDistanceTo(points[otherIndices[indexer[3]]],points[otherIndices[indexer[4]]],viewPoint,numbers,indexer[0]);
    elsif (otherIndices.length==1||indexer[2]==0)
      #Get distance.
      numbers[4]=StinomMathXE.getDistance(viewPoint,points[otherIndices[0]],indexer[0],numbers[0]);
    end
    #default to indices draws before if like equal.
    #X E
    return numbers[3]<=numbers[4];
    #X E
  end
  #X E
end
#X E
#8/9/2023, 2:08PM, done StinomMathXE. 2:09PM.
#8/3/2023, 4:14PM, done StinomMathXE.
#StinomDrawXE is a main class for using Stinom.
#7/26/2023, 2:53PM, start. 6:18PM, done, X E.
class StinomDrawXE
  #7/19/2024, 6:17PM, start making variables on this not each time. 6:18PM, X E.
  #7/26/2023, 2:54PM, start variables. 8/1/2023, 6:00PM, start fixes. 6:01PM, done.
  attr_accessor :points, :points2d, :shapes, :drawOrder, :shapeIndex, :pointIndex, :xDimen, :yDimen, :zDimen, :viewPoint, :viewAtPoint, :ranks;
  #7/26/2023, 2:57PM, done variables, X E. 2:59PM, added dimens, X E. 3:00PM, added view points, X E.
  #8/3/2023, 4:16PM, done variable.
  #8/9/2023, 2:13PM, done variables.
  #Make an instance, all things have an affect.
  #7/26/2023, 2:58PM, start. 3:10PM, done.
  def initialize(viewPoint, viewAtDimens, x=0, y=1, z=2, pointCapacity=0, shapeCapacity=0)
    @viewPoint=viewPoint;
    @viewAtPoint=viewAtDimens;
    @xDimen=x;
    @yDimen=y;
    @zDimen=z;
    #8/1/2023, 6:16PM, fix.
    @drawOrder=Array.new(shapeCapacity,0);
    @points=Array.new(pointCapacity,nil);
    @points2d=Array.new(pointCapacity,nil);
    @shapes=Array.new(shapeCapacity,nil);
    @shapeIndex=0;
    @pointIndex=0;
    #X E
  end
  #X E
  #reset so you can begin inputs again.
  #7/2/2024, 11:36AM, 11:37AM, start. 11:37AM, done.
  def reset()
    @pointIndex=0;
    @shapeIndex=0;
    #X E
  end
  #X E
  #8/9/2023, 2:20PM, done initialize.
  #8/3/2023, 4:20PM,done constructor. 4:21PM.
  #Add a 3d+ point.
  #7/26/2023, 4:45PM, start. 4:49PM, done. 4:50PM, fix.
  def addPoint(point)
    if (@points.length==@pointIndex)
      @points.push(point);
    else
      @points[@pointIndex]=point;
    end
    @pointIndex+=1;
    #X E
  end
  #X E
  #8/9/2023, 2:24PM, done addPoint.
  #8/3/2023, 4:22PM, done addPoint. 4:23PM, fix to it.
  #Add a shape made of indices of points as input.
  #7/26/2023, 4:49PM, start.  4:51PM, done, X E.
  def addShape(shape)
    if (@shapes.length==@shapeIndex)
      @shapes.push(shape);
    else
      @shapes[@shapeIndex]=shape;
    end
    @shapeIndex+=1;
    #X E
  end
  #X E
  #8/9/2023, 2:27PM, done addShape.
  #8/3/2023, 4:24PM, done addShape.
  #Set 2d point values based on 3d+ point values.
  #7/26/2023, 4:52PM, start. 5:07PM, done. 5:14PM, fix.
  def set2dPoints(roundWith=1.0, shouldRound=false,precPad=0.0)
    #First make points2d correct length.
    if (@pointIndex>@points2d.length)
      @points2d=Array.new(@pointIndex,nil);
    end
    #Next initialize variables.
    @index=@pointIndex-1;
    @funcIndex=0;
    @point=Array.new(@viewPoint.length,0.0);
    #Set 2d points.
    while (@index != -1) do
      @points2d[@index]=StinomMathXE.to2dPoint(@points[@index],@viewPoint,
      @viewAtPoint,@xDimen,@yDimen,@zDimen,roundWith,shouldRound,precPad,@funcIndex,@point);
      @index-=1;
    end
    #X E
  end
  #X E
  #Offset 2d points by a value set.
  #3/12/2024, 7:00PM, start. 7:02PM, done and fixed set2dPoints. X E.
  def offset(offsets=[0.0,0.0])
    @index=@pointIndex-1;
    while (@index != -1) do
      if (@points2d[@index] != nil)
        @points2d[@index][0]+=offsets[0];
        @points2d[@index][1]+=offsets[1];
      end
      @index-=1;
    end
    #X E
  end
  #X E
  #12/17/2024, 7:03PM, start. 7:04PM, done.
  def reverseX()
    @index=@pointIndex-1;
    while (@index != -1) do
      if (@points2d[@index] != nil)
        @points2d[@index][0] = -@points2d[@index][0];
      end
      @index-=1;
    end
    #X E
  end
  #X E
  #12/17/2024, 7:04PM, start. 7:05PM, done. 7:07PM, done. X E.
  def reverseY()
    @index=@pointIndex-1;
    while (@index != -1) do
      if (@points2d[@index] != nil)
        @points2d[@index][1] = -@points2d[@index][1];
      end
      @index-=1;
    end
    #X E
  end
  #X E
  #8/9/2023, 2:33PM, done set2dPoints. 2:34PM.
  #8/3/2023, 4:29PM, done set2dPoints.
  #Set draw order of all shapes.
  #7/26/2023, 5:09PM, start. 6:18PM, done, X E. 3/12/2024, 6:52PM, start fixes. 7:00PM, done.
  def setDrawOrder()
    #Check if nothing to order.
    if (@shapeIndex<2)
      return;
    end
    #First make draw order correct size.
    if (@drawOrder.length<@shapeIndex)
      @drawOrder=Array.new(@shapeIndex,0);
    end
    #First initialize some variables.
    if (@numbers==nil)
      @numbers=Array.new(18,0.0);
    end
    if (@ranks==nil)
      @ranks=Array.new(@shapeIndex,-1);
    end
    if (@ranks.length != @shapeIndex)
      @ranks=Array.new(@shapeIndex,-1);
    end
    if (@indices1==nil)
      @indices1=Array.new(5,0);
    end
    if (@vector==nil)
      @vector=Array.new(@viewPoint.length,0.0);
    end
    @indices=[@ranks.length-1,0,0];
    #initial compare.
    if (StinomMathXE.shouldDrawBefore?(@viewPoint,@points,@points2d,@shapes[@indices[0]-1],@shapes[@indices[0]],@indices1,@numbers,@vector))
      @ranks[@indices[0]-1]=1;
      @ranks[@indices[0]]=0;
    else
      @ranks[@indices[0]]=1;
      @ranks[@indices[0]-1]=0;
    end
    #Prepare and do rest. This is basically binary sort with input to already sorted.
    @indices[0]-=2;
    while (@indices[0] != -1) do
      #Set up bounds.
      @indices[1]=0;
      @indices[2]=@ranks.length-@indices[0]-2;
      while (@indices[1] != @indices[2])
        #Compare.
        if (StinomMathXE.shouldDrawBefore?(@viewPoint,@points,@points2d,@shapes[@indices[0]],@shapes[@ranks.rindex(((@indices[1]+@indices[2]).to_f()/2.0).round())],
        @indices1,@numbers,@vector))
          #Move lower bound up if before
          if (@indices[1]+1==@indices[2]||@indices[1]-1==@indices[2])
            @indices[1]=@indices[2];
          else
            @indices[1]=((@indices[1]+@indices[2]).to_f()/2.0).floor();
          end
        else
          #Move upper bound down if after
          if (@indices[1]+1==@indices[2]||@indices[1]-1==@indices[2])
            @indices[2]=@indices[1];
          else
            @indices[2]=((@indices[1]+@indices[2]).to_f()/2.0).ceil();
          end
        end
      end
      #Compare with found index.
      if (StinomMathXE.shouldDrawBefore?(@viewPoint,@points,@points2d,@shapes[@indices[0]],@shapes[@ranks.rindex(@indices[1])],
      @indices1,@numbers,@vector))
        #If before then rank as such
        @ranks[@indices[0]]=@indices[1]+1;
      else
        @ranks[@indices[0]]=@indices[1];
      end
      #Move all at or above found up one.
      @indices[1]=@ranks.length-1;
      while (@indices[1] != @indices[0]) do
        if (@ranks[@indices[1]]>=@ranks[@indices[0]])
          @ranks[@indices[1]]+=1;
        end
        @indices[1]-=1;
      end
      @indices[0]-=1;
    end
    #Make draw order based on ranks.
    @indices[0]=@ranks.length-1;
    while (@indices[0] != -1) do
      @drawOrder[@ranks.length-1-@indices[0]]=@ranks.rindex(@indices[0]);
      @indices[0]-=1;
    end
    #X E
  end
  #X E
end
#X E
#8/3/2023, 4:40PM, done SinomDrawXE.
#8/9/2023, 3:03PM, done SinomDrawXE.
