-- Useful for PostGIS queries
CREATE FUNCTION set_point_from_coords() RETURNS TRIGGER AS $$
BEGIN
  NEW.point := ST_SetSRID(ST_Point(NEW.coords[1], NEW.coords[2]), 4326);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql

-- Usage:
CREATE TABLE places (coords numeric(9,5)[], point geometry(Geometry, 4326));

CREATE TRIGGER set_point_from_coords
  BEFORE INSERT OR UPDATE OF coords ON places
  FOR EACH ROW
  EXECUTE PROCEDURE set_point_from_coords()
