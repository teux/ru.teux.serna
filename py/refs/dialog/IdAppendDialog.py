# coding=UTF-8

# Teux plugin for Serna, 2012

from os.path import dirname, join
from PyQt4 import QtGui, QtCore, uic
from PyQt4 import Qt 


class IdAppendDialog(QtGui.QDialog):
	
	def __init__(self, nodes):
		super(IdAppendDialog, self).__init__()
		uiPath = join(dirname(__file__), 'ui/idAppend.ui')
		uic.loadUi(uiPath, self)
		self._nodes = nodes
		self.buildDialog()
		self.fillData()
		self.setModal(True)
		
		
	def buildDialog(self):
		self.connect(self.lstNode, QtCore.SIGNAL('itemClicked(QListWidgetItem*)'), self.clickNode)
		
		
	def fillData(self):
		for n in self._nodes:
			t = n['name']
			if n['id'] != '':
				t += u' (' + n['id'] + ')' 
			self.lstNode.addItem(t)
		self.lstNode.setCurrentRow(self.lstNode.count()-1)
		self.clickNode(self.lstNode.item(self.lstNode.count()-1))
		
		
	def clickNode(self, node):
		if node:
			id = unicode(self._nodes[self.lstNode.row(node)]['id'])
			self.leId.setText(id)
			self.leId.selectAll()
			self.leId.setFocus()
			
	
	def id(self):
		''' Returns tuple of ancestor position and id '''
		return (self.lstNode.count() - self.lstNode.currentRow(), unicode(self.leId.text()).strip())
