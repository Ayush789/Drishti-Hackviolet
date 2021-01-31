from flask import Flask,jsonify
import math
from io import BytesIO
import json
import base64
from PIL import Image
from flask import request

class Review:

        def __init__(self,lat,lon,review):
                self.lat = lat
                self.lon = lon
                self.review = review
        def __str__(self):
                return "Lat {} Lon {} Rev {}".format(self.lat,self.lon,self.review)


ReviewList = []
def dist(x1,y1,x2,y2):
        return math.sqrt( (x1-x2)*(x1-x2)+ (y1-y2)*(y1-y2))


app = Flask(__name__)

@app.route('/')
def hello_world():
        im = Image.new("RGBA", (128, 128))
        pix = im.load()
        for x in range(128):
                for y in range(128):
                        pix[x,y] = (255,255,255,0)
                        for i in ReviewList:
                                if(dist(x,y,i.lat-28.6931474,i.lon-77.278937)<5):
                                        pix[x,y] = (0,0,255,255)

        buffered = BytesIO()
        im.save(buffered, format="PNG")
        img_str = base64.b64encode(buffered.getvalue())
        im.save("img2.png", "PNG")

        return img_str

resolution = (360,720)
#resolution = (18,36)

@app.route('/getmap',methods=['GET'])
def getMap():
        im = Image.new("RGBA", (resolution[0],resolution[1]))
        pix = im.load()
        print(resolution[0],resolution[1])

        try:
                n = request.args.get('n',type=float)
                s = request.args.get('s',type=float)
                w = request.args.get('w',type=float)
                e = request.args.get('e',type=float)
                for x in range(resolution[0]):
                        for y in range(resolution[1])[::-1]:
                                pix[x,y] = getcolor(min(n,s)+(abs(n-s)*(y))/resolution[1],min(e,w)+(abs(e-w)*(x))/resolution[0])

        except:
                print("error1")
        buffered = BytesIO()
        im.save(buffered, format="PNG")
        img_str = base64.b64encode(buffered.getvalue())
        im.save("img2.png", "PNG")
        return img_str

@app.route('/gettowermap',methods=['GET'])
def getTowerMap():
        im = Image.new("RGBA", (resolution[0],resolution[1]))
        pix = im.load()
        print(resolution[0],resolution[1])

        try:
                n = request.args.get('n',type=float)
                s = request.args.get('s',type=float)
                w = request.args.get('w',type=float)
                e = request.args.get('e',type=float)
                for x in range(resolution[0]):
                        for y in range(resolution[1])[::-1]:
                                pix[x,y] = getTowercolor(min(n,s)+(abs(n-s)*(y))/resolution[1],min(e,w)+(abs(e-w)*(x))/resolution[0])

        except:
                print("error1")
        buffered = BytesIO()
        im.save(buffered, format="PNG")
        img_str = base64.b64encode(buffered.getvalue())
        im.save("img2.png", "PNG")

        return img_str

@app.route('/addreview',methods=['GET'])
def addReview():
        try:
                lat = request.args.get('lat',type = float)
                lon = request.args.get('lon',type = float)
                rev = request.args.get('rev',type = int)

                print("Received: ",lat,lon,rev)
                ReviewList.append(Review(lat,lon,rev))
        except:
                print("error1")
        s = ""
        for i in ReviewList:
                s=s+"Lat "+str(i.lat)+" Lon "+str(i.lon) + " Rev " + str(i.review)+"\n"
        with open("points.txt","w") as f:
                f.write(s)
        print(s)
        return s


def getcolor(x1,y1):
        val = 0
        changed = False
        for i in ReviewList:
                d = dist(x1,y1,i.lat,i.lon)
                #print(x1,y1,i.lat,i.lon,d)
                #if (abs(x1-i.lat) <0.00001) or (abs(y1-i.lon)<0.00001):
                        #return(0,0,0,255)
                if(d<0.0001):
                        #print("Match",x1,y1)
                        #print(changed)

                        changed = True
                        if(i.review==1):
                                val=val-1
                        elif(i.review==3):
                                val=val+1
        if not changed:
                return (255,255,255,0)
        if(val>0):
                return(0,255,0,255)
        elif(val<0):
                if(val>-5):
                        #print(255,0,0,-val*51)
                        return(255,0,0,-val*51)
                else:
                        return(255,0,0,255)
        else:
                return(255,255,0,255)

TowerList = [Review( 28.543087 , 77.19317380000001,1),Review( 28.54309 , 77.193179,3)]

def getTowercolor(x1,y1):
        val = 0
        changed = False
        for i in TowerList:
                d = dist(x1,y1,i.lat,i.lon)
                #print(x1,y1,i.lat,i.lon,d)
                #if (abs(x1-i.lat) <0.00001) or (abs(y1-i.lon)<0.00001):
                        #return(0,0,0,255)
                if(d<0.0007):
                        #print("Match",x1,y1)
                        #print(changed)

                        changed = True
                        if(i.review==1):
                                val=val-1
                        elif(i.review==3):
                                val=val+1
        if not changed:
                return (255,255,255,0)
        if(val>0):
                return(0,255,0,255)
        elif(val<0):
                if(val>-5):
                        #print(255,0,0,-val*51)
                        return(255,0,0,-val*51)
                else:
                        return(255,0,0,255)
        else:
                return(255,255,0,255)
