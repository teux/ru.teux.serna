# coding=UTF-8

# Teux plugin for Serna, 2012

from os import stat, access, R_OK
from PyQt4.QtCore import QString 

from SernaApi import *
import meta
from lib import *


class FilterIds():
	''' Holds list of ids and filtering parameters '''
	
	def __init__(self):
		self.ids = []
	 	self.tags = []		# looking tags
		self.pattern = ''	# looking id
		self._fids = []		# filtered ids (init before iteration)
	
	
	def __getitem__(self, link):
		''' Returns row number for the link '''
		link = link.partition('#')[2] if r'#' in link else ''
		link = link.partition('/')
		for fid in self._fids:
			if fid['topicId'] == link[0] and fid['id'] == link[2]:
				return self._fids.index(fid)
		return -1
		
		
	def __iter__(self):
		class Iterator:
			def __init__(self, parent): self._ids = list(parent._fids)
			def __iter__(self): return self
			def next(self):
				try:
					return self._ids.pop(0)
				except IndexError:
					raise StopIteration
		self._FilterIds()
		return Iterator(self)
		
	
	def _FilterIds(self):
		''' Returns matched ids including topics with matched subtargets '''
		fids = map(self._matches, self.ids)
		# build tree of topics/targets
		hids = []
		for id in fids:
			if not id['id']:
				hids.append([id])
			else:
				hids[len(hids)-1].append(id)
		# mark topic if contains matched targets
		for topic in hids:
			truth = [id['match'] for id in topic]
			topic[0]['match'] = reduce(lambda x,y: x or y, truth)
		self._fids = filter(lambda id: id['match'], fids)
	
	
	def _matches(self, id):
		''' Marks id that is matches conditions '''
		mid = id['id'] if id['id'] else id['topicId']
		# mark True if matches 
		id['match'] = True \
			if (not self.tags or id['tag'] in self.tags) and \
				(self.pattern == '' or self.pattern.lower() in mid.lower()) \
			else False
		return id
		
	
	def id(self, row):
		''' Returns full id from filtered list '''
		topicId, id = self._fids[row]['topicId'], self._fids[row]['id'] 
		return '#%s%s'%(topicId, '/'+id if id else '')
	
	
	def tag(self, row):
		''' Returns tag from filtered list '''
		return self._fids[row]['tag']


class FileTargets:
	''' Loads, holds and returns targets (#id/id) from file '''
	
	def __init__(self, file, active):
		self._file = file
		self._mtime = 0
		self._ids = []
		self._active = active
		self._rescaned = False
		self._trimLen = 80
		
	
	def ids(self):
		''' Returns list of ids [{'topicId', 'id', 'tag', 'text')] '''
		if self._active:
			return self._ids if self._rescaned \
				else self._rescanOpenedDoc()
		elif access(self._file, R_OK):
			return self._ids \
				if self._mtime >= stat(self._file).st_mtime \
				else self._rescanFile()
		else:
			self._ids = []
			return self._ids	# file inacessible
		
		
	def _rescanOpenedDoc(self):
		self._walkGrove(targets._doc.structEditor().sourceGrove())
		self._rescaned = True
		return self._ids
	
	
	def _rescanFile(self):
		self._walkGrove(Grove().buildGroveFromFile(self._file))
		self._mtime = stat(self._file).st_mtime
		return self._ids
	
	
	def _walkGrove(self, grove):
		ids = []
		# root topic
		root = grove.document().documentElement()
		topicId = vof('@id', root)
		topicLevel = 1	# for calculating targets levels
		ids.append({
			'topicId': topicId,
			'id': '',
			'tag': unicode(root.nodeName()),
			'text': vof('title', root),
			'level': 0
		})
		# descendants
		for node in nset('descendant::*[string-length(@id) > 0]', root):
			tag = unicode(node.nodeName())
			isTarget = nset('self::*[name(*[1])="title" and ' + \
				'count(ancestor::*[name(*[1])="title"]) = count(ancestor::*)]', \
				node).firstNode().isNull()
			if isTarget:
				id = vof('@id', node)
				descr = vof('self::*//node()', node)
				descr = unicode(QString(descr).simplified())
				se = len(descr)
				if se > self._trimLen:
					se = descr.find(' ', self._trimLen)
					if se == -1:
						se = self._trimLen
					descr = descr[0:se] + '...'
				# nested level inside topic
				level = nset('ancestor::*[count(@id)>0]', node).size() - topicLevel
			else:	# topic
				topicId = vof('@id', node)
				topicLevel = nset('ancestor-or-self::*', node).size()
				level = topicLevel
				id = ''
				descr = vof('title', node)
				type = 'topic'
			ids.append({
				'topicId': topicId, 'id': id, 'tag': tag, 'text': descr, 'level': level})
		self._ids = ids
		
	
	def active(self, state=None):
		''' Marks active document or returns current mark '''
		if state == None:
			return self._active
		self._active = state
		self._rescaned = False	# need rescan active document


	def file(self):
		return self._file


	def acessible(self):
		''' Returns True if file is acessible or active '''
		return True if self._active or \
			access(self._file, R_OK) else False
		


class FileTargetsCollection:
	''' Holds FileTargets and creates objects on demand '''
	
	def __init__(self):
		self._files = []
		
	def __iter__(self):
		''' Returns file names and active states '''
		class Iterator:
			def __init__(self, parent):
				self._files = list(parent._files)
			def __iter__(self):
				return self
			def next(self):
				try:
					ft = self._files.pop(0)
					return ft.file(), ft.active() 
				except IndexError:
					raise StopIteration
		self.clearInacessable()
		return Iterator(self)
		
			
	def __getitem__(self, index):
		''' Returns FileTargets by index '''
		return self._files[index]

	
	def setActive(self, doc, file):
		''' Sets active file and raises it on top  '''
		self._doc = doc
		self.append(file, True)
		# resets active marks
		for f in self._files:
			f.active(False)
		self._files[0].active(True)
		self.clearInacessable()
		
	
	def append(self, file, active=False):
		''' Appends file to begin of collection.
				Returns False if file inacessible '''
		ft = None
		for f in self._files:
			if f.file() == file:
				ft = f
				break
		ft = self._files.pop(self._files.index(ft)) \
			if ft else FileTargets(file, active)
		if ft.acessible():
			self._files.insert(0, ft)
			return True
		else:
			return False
				
	
	def clearInacessable(self):
		''' Removes unacessible FileTargets '''
		files = []
		for f in self._files:
			if f.acessible():
				files.append(f)
		self._files = files
		
	
targets = FileTargetsCollection()