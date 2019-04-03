import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

String queries[][] = { {"articles", "date", "copy"}, 
                       {"exhibitions", "aic_start_date", "description"},
                       {"events", "start_date", "description"} };

int year = 2010;
int month = 1;
List<Coordinate> points;

int SHE = 0;
int HE = 1;

class Coordinate {
  float x, y;

  Coordinate (float px, float py) {
    x = px;
    y = py;
  }
}

void setup() {
  fullScreen();
  frameRate(4);

  PFont f = createFont("RobotoMono-Regular.ttf", 18);
  textFont(f);

  points = new ArrayList<Coordinate>();
}

void draw() {
  if ((year < year() && month <= 12) || (year == year() && month <= month())) {
    background(255);

    fill(#ff0000);
    textAlign(CENTER);
    text("she", width*.25, height-20);
    text("he", width*.75, height-20);

    stroke(0);
    line(width/2, height/12, width/2, height-(height/12) );

    drawAllPoints();

    if (year == year() && month == month()) {
      fill(#ff0000);
      textAlign(LEFT);
      text("2010–Present", 20, (height/12)-10);
    }
    else {
      fill(#ff0000);
      textAlign(RIGHT);
      text(month + "/" + year, 90, (height/12)-10);

      int she = 0;
      int he = 0;

      for (int q = 0; q < queries.length; q++) {
        // For each query type, get all text content for a given month: >= the first of the month and < the first
        // of the next month.
        JSONObject json = loadJSONObject("https://aggregator-data.artic.edu/api/v1/" + queries[q][0] + "/search"
          + "?query[range][" + queries[q][1]+ "][gte]=" + year + "-" + nf(month, 2)+ "-01"
          + "&query[range][" + queries[q][1]+ "][lt]=" + (month == 12 ? year+1 : year) + "-" + (month == 12 ? "01" : nf(month+1, 2)) + "-01"
          + "&query[range][" + queries[q][1]+ "][format]=yyyy-MM-dd"
          + "&fields=" + queries[q][2]
          + "&limit=120");

        JSONArray data = json.getJSONArray("data");

        // Loop through all the returned records and count he/she pronouns
        for (int i = 0; i < data.size(); i++) {
          if (!data.getJSONObject(i).isNull(queries[q][2])) {
            String copy = data.getJSONObject(i).getString(queries[q][2]);

            String[] strings = copy.toLowerCase().split("[ ,\\.']");

            for (String str : strings) {
              if (str.matches("her[s]?")) {
                she++;
              }
              if (str.equals("she")) {
                she++;
              }
              if (str.equals("him")) {
                he++;
              }
              if (str.equals("his")) {
                he++;
              }
              if (str.equals("he")) {
                he++;
              }
            }
          }
        }
      }

      for (int i = 0; i < she; i++) {
        addPoint(SHE, she);
      }
      for (int i = 0; i < he; i++) {
        addPoint(HE, he);
      }

      //    println((month < 10 ? " " : "") + month + "/" + year + " she: " + String.format("%4d", she) + " " + new String(new char[she]).replace('\0', 'x'));
      //    println((month < 10 ? " " : "") + month + "/" + year + "  he: " + String.format("%4d", he) + " " + new String(new char[he]).replace('\0', '-'));

      month++;
      if (month == 13) {
        month = 1;
        year++;
        println();
      }
    }
  }
}

void addPoint(int shehe, int total) {
  float x = random(10+(shehe == SHE ? 0 : width/2), (width/2)+(shehe == SHE ? 0 : width/2)-20);
  float y = random(20, height-50);

  points.add(new Coordinate(x, y));

  noStroke();
  fill(255, 0, 0);
  square(x, y, 10);
}

void drawAllPoints() {
  for (int i = 0; i < points.size(); i++) {
    noStroke();
    fill(200, 50);

    Coordinate c = points.get(i);
    square(c.x, c.y, 10);
  }
}
