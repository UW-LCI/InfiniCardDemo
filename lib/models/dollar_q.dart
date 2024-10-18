import 'dart:math';

class GesturePoint {
  double x, y;
  int strokeId;
  double? time;
  double? pressure;
  int index;

  GesturePoint(this.x, this.y, this.strokeId,
      [this.time, this.pressure, this.index = -1]);

  double distanceTo(GesturePoint other) {
    var dx = x - other.x;
    var dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }
}

class MultiStrokePath {
  List<GesturePoint> strokes;
  String name;

  MultiStrokePath(this.strokes, [this.name = '']);
}

class DollarQ {
  List<MultiStrokePath> _templates = [];
  final int cloudSize;
  final int lutSize;

  DollarQ({this.cloudSize = 32, this.lutSize = 64});

  set templates(List<MultiStrokePath> newTemplates) {
    _templates = newTemplates.map((t) {
      var normalizedPoints = normalize(t.strokes, cloudSize, lutSize);
      for (int i = 0; i < normalizedPoints.length; i++) {
        normalizedPoints[i].index = i;
      }
      return MultiStrokePath(normalizedPoints, t.name);
    }).toList();
  }

  List<MultiStrokePath> get templates => _templates;

  Map<String, dynamic> recognize(MultiStrokePath points) {
    var score = double.infinity;
    var normalizedPoints = normalize(points.strokes, cloudSize, lutSize);
    for (int i = 0; i < normalizedPoints.length; i++) {
      normalizedPoints[i].index = i;
    }
    var updatedCandidate = MultiStrokePath(normalizedPoints);

    MultiStrokePath? bestTemplate;
    int bestTemplateIndex = -1;

    for (int i = 0; i < _templates.length; i++) {
      var template = _templates[i];
      var d = cloudMatch(updatedCandidate, template, cloudSize, score);
      if (d < score) {
        score = d;
        bestTemplate = template;
        bestTemplateIndex = i;
      }
    }

    if (bestTemplate != null) {
      return {
        'template': bestTemplate.strokes,
        'templateIndex': bestTemplateIndex,
        'score': score,
      };
    }

    return {};
  }

  List<GesturePoint> normalize(
      List<GesturePoint> points, int cloudSize, int lookUpTableSize) {
    var resampled = resample(points, cloudSize);
    var translated = translateToOrigin(resampled);
    var scaled = scale(translated, lookUpTableSize);
    return scaled;
  }

  List<GesturePoint> resample(List<GesturePoint> points, int n) {
    if (n <= 1 || n > 1000) {
      throw ArgumentError('Parameter n must be between 2 and 1000');
    }
    var pathLen = pathLength(points);
    var interval = pathLen / (n - 1);
    var D = 0.0;
    var newPoints = <GesturePoint>[points[0]];
    var i = 1;
    const int maxPoints = 1000;

    while (i < points.length && newPoints.length < maxPoints) {
      var d = points[i].distanceTo(points[i - 1]);
      if (D + d >= interval) {
        var t = (interval - D) / d;
        var qx = points[i - 1].x + t * (points[i].x - points[i - 1].x);
        var qy = points[i - 1].y + t * (points[i].y - points[i - 1].y);
        var q = GesturePoint(
            qx, qy, points[i].strokeId, points[i].time, points[i].pressure);
        newPoints.add(q);
        D = 0.0;
      } else {
        D += d;
        i++;
      }
    }

    if (newPoints.length == n - 1 && i < points.length) {
      newPoints.add(points.last);
    }

    return newPoints;
  }

  List<GesturePoint> translateToOrigin(List<GesturePoint> points) {
    var centroid = calculateCentroid(points);
    return points
        .map((p) => GesturePoint(p.x - centroid.x, p.y - centroid.y, p.strokeId,
            p.time, p.pressure, p.index))
        .toList();
  }

  GesturePoint calculateCentroid(List<GesturePoint> points) {
    var sumX = 0.0, sumY = 0.0;
    for (var p in points) {
      sumX += p.x;
      sumY += p.y;
    }
    return GesturePoint(sumX / points.length, sumY / points.length, 0);
  }

  List<GesturePoint> scale(List<GesturePoint> points, int m) {
    var minX = points.map((p) => p.x).reduce(min);
    var maxX = points.map((p) => p.x).reduce(max);
    var minY = points.map((p) => p.y).reduce(min);
    var maxY = points.map((p) => p.y).reduce(max);

    var size = max(maxX - minX, maxY - minY);
    return points
        .map((p) => GesturePoint(
            (p.x - minX) * (m - 1) / size,
            (p.y - minY) * (m - 1) / size,
            p.strokeId,
            p.time,
            p.pressure,
            p.index))
        .toList();
  }

  double cloudMatch(
      MultiStrokePath points, MultiStrokePath template, int n, double minimum) {
    var step = sqrt(n).round();
    var lowerBound1 = computeLowerBound(points.strokes, template.strokes, step, n);
    var lowerBound2 = computeLowerBound(template.strokes, points.strokes, step, n);
    var minSoFar = minimum;

    for (var i = 0; i < n - 1; i += step) {
      var index = i ~/ step;
      if (lowerBound1[index] < minSoFar) {
        var distance =
            cloudDistance(points.strokes, template.strokes, n, i, minSoFar);
        minSoFar = min(minSoFar, distance);
      }
      if (lowerBound2[index] < minSoFar) {
        var distance =
            cloudDistance(template.strokes, points.strokes, n, i, minSoFar);
        minSoFar = min(minSoFar, distance);
      }
    }
    return minSoFar;
  }

  double cloudDistance(List<GesturePoint> points, List<GesturePoint> template,
      int n, int start, double minSoFar) {
    var i = start;
    var unmatched = List.generate(n, (index) => index);
    var sum = 0.0;
    do {
      var index = -1;
      var minDist = double.infinity;
      for (var j in unmatched) {
        var d = points[i].distanceTo(template[j]);
        if (d < minDist) {
          minDist = d;
          index = j;
        }
      }
      if (index == -1) break;
      unmatched.remove(index);
      sum += (n - unmatched.length) * minDist;
      if (sum >= minSoFar) {
        return sum;
      }
      i = (i + 1) % n;
    } while (i != start);
    return sum;
  }

  List<double> computeLowerBound(List<GesturePoint> points,
      List<GesturePoint> template, int step, int n) {
    var lowerBound = <double>[];
    var summedAreaTable = <double>[];

    double sum = 0.0;
    for (var i = 0; i < n; i++) {
      var point = points[i];
      var minDist = double.infinity;
      for (var t in template) {
        var distance = point.distanceTo(t);
        if (distance < minDist) {
          minDist = distance;
        }
      }
      sum += minDist;
      summedAreaTable.add(sum);
    }

    lowerBound.add(sum);
    for (var i = step; i < n - 1; i += step) {
      var nextValue = lowerBound[0] +
          (i * (summedAreaTable.last)) -
          (n * (summedAreaTable[i - step < 0 ? 0 : i - step]));
      lowerBound.add(nextValue);
    }
    return lowerBound;
  }

  double pathLength(List<GesturePoint> points) {
    var length = 0.0;
    for (var i = 1; i < points.length; i++) {
      length += points[i].distanceTo(points[i - 1]);
    }
    return length;
  }
}