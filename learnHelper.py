#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2016-07-03 20:45:55
# @Author  : Guo Chen 
# @Email   : guo-c14@foxmail.com

import os, re
import requests
from lxml import etree

url = 'https://learn.tsinghua.edu.cn/MultiLanguage/lesson/teacher/loginteacher.jsp'
url1 = 'http://info.tsinghua.edu.cn/Login'
user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36'
headers = {'User-Agent' : user_agent}
form_data = {'userid':'2012345678', 'userpass':'**********', 'submit1':'登录', 'roleType':'3'}
form_data1 = {"redirect":"NO",
            "userName":"2012345678", "password":"**********"}
urlligin = 'http://learn.tsinghua.edu.cn/study/login.action'

form = {'roleType':'3'}
s = requests.session()
# 登录
response = s.post(url, data = form_data, headers = headers)
# 所有课程列表
response1 = s.get('http://learn.tsinghua.edu.cn/MultiLanguage/lesson/student/MyCourse.jsp?typepage=3')
# 课程公告列表
print ""

courseURLList_temp = re.findall('course_id=(\d*)\D*\s(.*?)</a>', response1.text, re.S)
base = 'http://learn.tsinghua.edu.cn/MultiLanguage/public/bbs/getnoteid_student.jsp?course_id='

courseURLList = []
courseList = []
for i in xrange(len(courseURLList_temp)):
    courseList.append([])
    courseList[i] = courseURLList_temp[i]
    courseURLList.append(base + courseURLList_temp[i][0])
    print i+1,
    for j in courseList[i]:
        print j,
    print ""

response2 = s.get(courseURLList[14])

bbsList_temp = re.findall('''&id=(\d*)&course_id=(\d*)'>(.*?)</a>.*?height=25>(.*?)</td>.*?height=25>(.*?)</td>.*?height=25>(.*?)</td>''', response2.text, re.S)
bbsList = []
for i in xrange(len(bbsList_temp)):
    bbsList.append([])
    bbsList[i] = bbsList_temp[i][0], bbsList_temp[i][1], bbsList_temp[i][2].replace("<font color=red>", "").replace("</font>", ""), bbsList_temp[i][3], bbsList_temp[i][4]
    print i+1,
    for j in bbsList[i]:
        print j,
    print ""

base1 = 'http://learn.tsinghua.edu.cn/MultiLanguage/public/bbs/note_reply.jsp?bbs_type=课程公告&id=||BBSID||&course_id=||COURSEID||'
response3 = s.get(base1.replace('||BBSID||', str(bbsList[1][0])).replace('||COURSEID||', str(bbsList[1][1])))
print response3.text
temp = re.findall('''colspan="3">(.*?)</td>.*?overflow:hidden;">\s*(.*?)\s''', response3.text, re.S)
for i in temp:
    for j in i:
        print j,

base2 = "http://learn.tsinghua.edu.cn/MultiLanguage/lesson/student/hom_wk_detail.jsp?id=600679&course_id=111995"
response4 = s.get(base2)



base3 = 'http://learn.tsinghua.edu.cn/MultiLanguage/lesson/student/download.jsp?course_id=127515'

response5 = s.get(base3)


print response5.text

