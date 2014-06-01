# coding=UTF-8

# Teux plugin for Serna, 2012

from os import listdir, stat, access, R_OK
from os.path import dirname, join, normpath
from PyQt4 import QtXml


class DitamapKeys:
	''' Loads, holds and returns keys from ditamap '''
	
	def __init__(self, ditamap, openState=False):
		self._ditamap = ditamap
		self._openState = openState
		self._mtime = 0
		self.clean()
		self.loadData()

	
	def __getitem__(self, key):
		self.loadData()
		try:
			return self._keys[key]
		except KeyError:
			return ''
			
			
	def __iter__(self):
		class Iterator:
			def __init__(self, parent):
				self._keys = [key for key in parent._keys]
			def __iter__(self): return self
			def next(self):
				try:
					return self._keys.pop(0)
				except IndexError:
					raise StopIteration
		self.loadData()
		return Iterator(self)

	
	def clean(self):
		''' Cleans object '''
		self._keys = {}
		self._topicrefs = []
		self._lastSelected = -1
		
		
	def loadData(self):
		''' Checks ditamap modification time and loads (reloads) keys and topicrefs '''
		if not access(self._ditamap, R_OK):
			self.clean()
			return
		if self._mtime < stat(self._ditamap).st_mtime:
			self.clean()
			# parse ditamap
			dom = QtXml.QDomDocument()
			if dom.setContent(open(self._ditamap, 'r').read()):
				self.loadKeys(dom)
				self.loadTopicrefs(dom)
				self._mtime = stat(self._ditamap).st_mtime
	
	
	def loadKeys(self, dom):
		''' Loads keys '''
		kd = dom.elementsByTagName('keydef')
		for i in range(kd.count()):
			keys = unicode(kd.item(i).toElement().attribute('keys'))
			if keys != '':
				text = []
				kw = kd.item(i).toElement().elementsByTagName('keywords')
				for t in range(kw.count()):
					text.append(unicode(kw.item(t).toElement().text()))
				text = ' '.join(text)
				# add keys
				for key in keys.split(' '):
					self._keys[key] = text

	
	def loadTopicrefs(self, dom):
		''' Loads topicrefs from opened ditamap '''
		if self._openState:
			baseDir = dirname(self._ditamap)
			tr = dom.elementsByTagName('topicref')
			for i in range(tr.count()):
				href = unicode(tr.item(i).toElement().attribute('href'))
				self._topicrefs.append(normpath(join(baseDir, href)).replace('\\','/'))
	
	
	def count(self):
		return len(self._keys)
		
	
	def ditamap(self):
		return self._ditamap
		
	
	def isOpen(self):
		return self._openState
		
		
	def isHolderOf(self, file):
		''' Returns True if ditamap holds topicref on file '''
		self.loadData()
		try:
			i = self._topicrefs.index(file)
			return True
		except ValueError:
			return False
			
	
	def selected(self, row=None):
		''' Returns or stores last selected key '''
		if row == None:
			return self._lastSelected
		else:
			self._lastSelected = row
		
	

class DitamapKeysCollection:
	''' Holds DitamapKeys objects and creates objects on demand '''
	
	def __init__(self):
		self._ditamaps = {'_absent': DitamapKeys('')}		# empty object for fallback

	
	def __getitem__(self, file):
		''' Returns DitampKeys for the file. If no object exists adds them. 
				First looks in opened ditamap, next in current and parent directory.
		'''
		for d in self._ditamaps.values():
			if d.isOpen() and d.isHolderOf(file):
				return d
		cd = self._findDitamap(dirname(file))
		pd = self._findDitamap(dirname(dirname(file)))
		path = cd if cd != '' else pd if pd != '' else '_absent'  
		 
		if path not in self._ditamaps:
			self._ditamaps[path] = DitamapKeys(path)
		return self._ditamaps[path]


	def _findDitamap(self, dir):
		''' Finds first ditamap in dir '''
		for i in listdir(dir):
			if i.endswith('ditamap'):
				return join(dir, i).replace('\\','/')
		return ''
		
			
	def openDitamap(self, path):
		''' Registers opened ditamap in keys collection  '''
		self._ditamaps[path] = DitamapKeys(path, openState=True)
		
		
	def closeDitamap(self, path):
		''' Remove closed ditamap from keys collection '''
		if path in self._ditamaps:
			del self._ditamaps[path] 


keys = DitamapKeysCollection()