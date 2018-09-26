from flask_sqlalchemy import SQLAlchemy
import datetime
db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'user'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    pwd_hash = db.Column(db.String(120), nullable=False)
    num_maps_created = db.Column(db.Integer, default = 0)
    maps = relationship("Beat_Map")

    def hash_password(self, password):
        self.pwd_hash = pwd_context.encrypt(password)
    
    def verify_password(self, password):
        return pwd_context.verify(password, self.pwd_hash)

    def __init__(self, username, password):
        self.username = username
        self.hash_password(password)

    def __repr__(self):
        return '<User %r>' % self.username

class Song(db.Model):
    __tablename__ = 'song'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Integer, primary_key = True)
    
    # Should plan for being unable to get some song data 
    bpm = db.Column(db.Integer, nullable = True)
    genre = db.Column(db.String(80), nullable=True)
    artist = db.Column(db.String(80), nullable=True)
    time_signature = db.Column(db.Integer, nullable=True)
    beat_map = relationship("Beat_Map", uselist=False, back_populates='song')

    def __init__(self, name, bpm=None, genre=None, time_signature=None)
        self.name = name
        self.bpm = bpm
        self.genre = genre
        self.time_signature = time_signature

        print("created song number {} with name {}".format(self.id, self.name))

    def __repr__(self):
        return '<Map %r>' % self.name
        
class Beat_Map(db.Model):
    __tablename__ = 'map'
    
    # auto-increments.
    id = db.Column(db.Integer, primary_key=True)
    avg_difficulty = db.Column(db.Integer, nullable=True)
    creator_id = Column(Integer, ForeignKey('user.id'))
    song_id = Column(Integer, ForeignKey('song.id'))
    song = relationship("Song", back_populates="song")

    def __init__(self, creator_id)
        self.creator_id = creator_id
    def __repr__(self):
        return '<Map {} build for song {} >'.format( self.id, )

class Play(db.Model):
    __tablename__ = 'play'
    
    id = db.Column(db.Integer, primary_key = True)
    time_played - db.Column(DateTime, default = datetime.datetime.utcnow)
    
    player_played = db.Column(db.Integer, db.ForeignKey('user.id'))
    map_played = db.Column(db.Integer, db.ForeignKey('map.id'))
    
    player = relationship("User", backref = backref("play", cascade='all, delete-orphan'))
    beat_map = relationship("Beat_Map", backref = backref("play", cascade = 'all, delete-orphan'))

    def __init__(self, player, map):
        self.player_played = player
        self.map_played = map