const tableLogbook = '''
  CREATE TABLE IF NOT EXISTS logbook (
    uuid TEXT PRIMARY KEY,
    date TEXT NOT NULL,
    departure_place TEXT,
    departure_time TEXT,
    arrival_place TEXT,
    arrival_time TEXT,
    aircraft_model TEXT,
    reg_name TEXT,
    se_time TEXT,
    me_time TEXT,
    mcc_time TEXT,
    total_time TEXT,
    day_landings INTEGER,
    night_landings INTEGER,
    night_time TEXT,
    ifr_time TEXT,
    pic_time TEXT,
    co_pilot_time TEXT,
    dual_time TEXT,
    instructor_time TEXT,
    sim_type TEXT,
    sim_time TEXT,
    pic_name TEXT,
    remarks TEXT,
    update_time INTEGER
  );

  CREATE UNIQUE INDEX IF NOT EXISTS logbook_uuid ON logbook(uuid);
  ''';

const viewLogbook = '''
  CREATE VIEW IF NOT EXISTS logbook_view
  AS
  SELECT uuid, date,
    substr(date,7,4) || substr(date,4,2) || substr(date,0,3) as m_date,
    departure_place, departure_time, arrival_place, arrival_time,
    aircraft_model, reg_name, se_time, me_time, mcc_time, total_time,
    iif(day_landings='',0,day_landings) as day_landings,
    iif(night_landings='',0,night_landings) as night_landings,
    night_time, ifr_time, pic_time, co_pilot_time, dual_time, instructor_time,
    sim_type, sim_time, pic_name, remarks, update_time
  FROM logbook;
''';

const deletedItems = '''
  CREATE TABLE IF NOT EXISTS deleted_items (
      uuid TEXT PRIMARY_KEY,
      table_name TEXT NOT NULL,
      delete_time TEXT NOT NULL
  );
''';

const airportTable = '''
  CREATE TABLE IF NOT EXISTS airports (
    icao TEXT PRIMARY_KEY,
    iata TEXT,
    name TEXT,
    city TEXT,
    country TEXT,
    elevation INTEGER,
    lat REAL,
    lon REAL
  );

  CREATE UNIQUE INDEX IF NOT EXISTS airports_icao ON airports(icao);
  CREATE INDEX IF NOT EXISTS airports_iata ON airports(iata);
''';

const attachmentTable = '''
  CREATE TABLE IF NOT EXISTS attachments (
      uuid TEXT PRIMARY_KEY,
      record_id TEXT,
      document_name TEXT,
      document BLOB
  );
''';
