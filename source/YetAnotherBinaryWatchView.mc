import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.Time.Gregorian as Greg;

class YetAnotherBinaryWatchView extends WatchUi.WatchFace {

    protected var colorSelected = Graphics.COLOR_ORANGE;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Time
        var clockTime = System.getClockTime();

        // Date
        var date = Greg.info(Time.now(), Time.FORMAT_SHORT);
        var date_medium = Greg.info(Time.now(), Time.FORMAT_MEDIUM);
      
        var font = Graphics.FONT_SYSTEM_TINY; 

        // Load battery percentage.
        var systemStats = System.getSystemStats();
        var battery = systemStats.battery;


        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Battery
        self.displayBattery(dc, battery);

        // Secondes
        var secondes = self.getBits(clockTime.sec, 2);
        self.displaySecondes(dc, secondes);

        // Hours and minutes
        var xHours = Math.round(dc.getWidth() * 0.2).toNumber();
        var yHours = Math.round(dc.getHeight() * 0.58).toNumber();
        var xMinutes = Math.round(dc.getWidth() * 0.815).toNumber();

        var hours = self.getBits(clockTime.hour, 2);
        self.displayBits(dc, hours, xHours, yHours, true);
        var minutes = self.getBits(clockTime.min, 2);
        self.displayBits(dc, minutes, xMinutes, yHours, true);


        // Date
        var xDay = Math.round(dc.getWidth() * 0.3).toNumber();
        var yDay = Math.round(dc.getHeight() * 0.2).toNumber();
        var xMonth = Math.round(dc.getWidth() * 0.708).toNumber();

        var day = self.getBits(date.day, 2);
        self.displayBits(dc, day, xDay, yDay, false);
        var month = self.getBits(date.month, 2);
        self.displayBits(dc, month, xMonth, yDay, false);

        // Day of week
        var xTextDate = Math.round(dc.getWidth() * 0.5).toNumber();
        var yTextDate = Math.round(dc.getHeight() * 0.1).toNumber();
        dc.setColor(self.colorSelected, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xTextDate, yTextDate, font, date_medium.day_of_week,  Graphics.TEXT_JUSTIFY_CENTER);
    }

    protected function displayBattery(dc, battery) {
        battery = Math.round(battery / 5).toNumber();
        var xBattery = Math.round(dc.getWidth() * 0.75).toNumber();
        var xBatteryInitial = xBattery;
        var yBattery = Math.round(dc.getHeight() * 0.7).toNumber();
        var rectangleWidth = Math.round(dc.getWidth() * 0.023).toNumber();
        var rectangleMargin = Math.round(dc.getWidth() * 0.005).toNumber();
        var colors = [
            0xe90741,
            0xf70845,
            0xf8154f,
            0xf82359,
            0xf83163, 
            0xf93e6e,
            0xf94c78,
            0xfa5a83,
            0xfa688d,
            0xfb7597,
            0xfb83a2,
            0xfb91ac,
            0xfc9fb6,
            0xfcacc1,
            0xfdbacb,
            0xfdc8d6,
            0xfed6e0,
            0xfee3ea,
            0xfff1f5,
        ];
        for(var i = 0; i < 19; i++) {
            if ((battery - 1) < i) {
                dc.setColor(Application.Properties.getValue("Grey"), Graphics.COLOR_TRANSPARENT);
                dc.drawRectangle(xBattery, yBattery, rectangleWidth, rectangleWidth);
            }
            else {
                dc.setColor(colors[i], Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(xBattery, yBattery, rectangleWidth, rectangleWidth);
            }
            xBattery = xBattery - rectangleWidth - rectangleMargin;
        }

        if (battery > 19) {
            var yLine = yBattery + Math.round(dc.getHeight() * 0.025).toNumber();
            dc.setColor(0xffffff, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(xBatteryInitial + rectangleWidth - rectangleMargin, yLine, xBattery + rectangleWidth, yLine);
        }

    }

    protected function displaySecondes(dc as Dc, bits) as Void {
        var xCenter = Math.round(dc.getWidth() * 0.5).toNumber();
        var yCenter = Math.round(dc.getHeight() * 0.5).toNumber();
        var radius = Math.round(dc.getWidth() * 0.15).toNumber();
        var tinyRadius = Math.round(dc.getWidth() * 0.02).toNumber();
        var marginYCircle = Math.round(dc.getHeight() * 0.025).toNumber();
        var marginXCircle = Math.round(dc.getWidth() * 0.04).toNumber();
        
        // Draw seconde units
        var startPoint;
        var endPoint;
        var angleCoefs = [1, 3, -3, -1];
        dc.setPenWidth(3);
        for (var i = 0 ; i < 4; i++) {
            startPoint = self.getPoint(dc, xCenter, yCenter, 0.06, angleCoefs[i]);
            endPoint = self.getPoint(dc, xCenter, yCenter, 0.12, angleCoefs[i]);
            if (bits[0][i] == 1) {
                dc.setColor(self.colorSelected, Graphics.COLOR_TRANSPARENT);
            }
            else {
                dc.setColor(Application.Properties.getValue("Grey"), Graphics.COLOR_TRANSPARENT);
            }
            dc.drawLine(startPoint[0], startPoint[1], endPoint[0], endPoint[1]);
        }
        dc.setPenWidth(1);

        // main circle
        dc.setColor(Application.Properties.getValue("LightGrey"), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(xCenter, yCenter + 1, radius);
        if (bits[1][0] == 1 && bits[1][2] == 1 && bits[1][0] == 1 && bits[0][0] == 1 && bits[0][3] == 1) {
            dc.setColor(Application.Properties.getValue("Red"), Graphics.COLOR_TRANSPARENT);
        }
        else {
            dc.setColor(self.colorSelected, Graphics.COLOR_TRANSPARENT);
        }
        dc.setPenWidth(1);
        dc.drawCircle(xCenter, yCenter, radius);

        // Tiny circle center 
        if (bits[1][0] == 1) {
            dc.setColor(self.colorSelected, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(xCenter, yCenter, tinyRadius);
        }
        else {
            dc.setColor(Application.Properties.getValue("Grey"), Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(xCenter, yCenter, tinyRadius);
        }
        

        // Tiny circle bottom center 
        var yTinyCircleCenter = Math.round(dc.getHeight() * (0.5+0.06)).toNumber();
        if (bits[1][1] == 1) {
            dc.setColor(self.colorSelected, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(xCenter, yTinyCircleCenter, tinyRadius);
        }
        else {
            dc.setColor(Application.Properties.getValue("Grey"), Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(xCenter, yTinyCircleCenter, tinyRadius);
        }
        

        // Tiny circle bottom 
        var yTinyCircleBottom = Math.round(dc.getHeight() * (0.5+0.12)).toNumber();
        if (bits[1][2] == 1) {
            dc.setColor(self.colorSelected, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(xCenter, yTinyCircleBottom, tinyRadius);
        }
        else {
            dc.setColor(Application.Properties.getValue("Grey"), Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(xCenter, yTinyCircleBottom, tinyRadius);
        }
    }


    protected function getPoint(dc as Dc, xInitial as Number, yInitial as Number, percentWidth as Float, angleCoef as Number) as Array<Number> {
        var segmentFullLenght = Math.round(dc.getWidth() * 0.1 ).toNumber();
        var segmentlenght = Math.round(dc.getWidth() * percentWidth).toNumber();
        var angle = angleCoef * segmentFullLenght * Math.PI / 30;
        var cosAngle = Math.cos(angle);
        var sinAngle = Math.sin(angle);
        var xLenght = sinAngle * segmentlenght;
        var yLenght = cosAngle * segmentlenght;
        return [xInitial + xLenght, yInitial + yLenght];
    }

    protected function displayBits(dc as Dc, bits , xInitial as Number, yInitial as Number, bigDisplay as Boolean) as Void {
        var bitWidth = Math.round(dc.getWidth() * 0.06).toNumber(); // 12
        var bitMargin = Math.round(bitWidth/4);
        if (!bigDisplay) {
            bitWidth = bitWidth / 2;
            bitMargin = bitMargin / 2;
        }
        var bitLine = []; 
        var y = yInitial;
        var x = xInitial;

        for (var lineIndex = 0; lineIndex < bits.size() ; lineIndex++) {
            bitLine = bits[lineIndex];
            if (bitLine instanceof Number) {
                bitLine = [bitLine];
            }
            for (var bitIndex = 0; bitIndex < bitLine.size() ; bitIndex++) {

                if (bitLine[bitIndex] == 1) {
                    dc.setColor(self.colorSelected, Graphics.COLOR_TRANSPARENT);
                    dc.fillRoundedRectangle(x, y, bitWidth, bitWidth, 2);
                }
                else {
                    dc.setColor(Application.Properties.getValue("Grey"), Graphics.COLOR_TRANSPARENT);
                    dc.drawRoundedRectangle(x, y, bitWidth, bitWidth, 2);
                }
                y = y - bitWidth - bitMargin;
            }
            y = yInitial;
            x = x - bitWidth - bitMargin;
        }
    }

    protected function getBits(number as Number, size as Number) as Array<Array<Number>> {        
        var bits = new[size];
        var divider = 1;
        for (var i = 0; i < size ; i++) {
            bits[i] = self.decToBin((number / divider) % 10, 4);
            divider = divider * 10;
        }
        return bits;
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    //! Calculate the binary version of decimal value
    function decToBin(dec as Number, size as Number) as Array<Number> {
        var bin = new[size] as Array<Number>;
        var i = 0;
        while (dec) {
            bin[i] = dec % 2;
            dec = dec / 2;
            i++;
        }
        return bin;
    }

}
