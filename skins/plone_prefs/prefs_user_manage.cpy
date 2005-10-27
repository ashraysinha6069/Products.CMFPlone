## Script (Python) ""
##bind container=container
##bind context=context
##bind namespace=
##bind script=script
##bind subpath=traverse_subpath
##parameters=users=[], resetpassword=[], delete=[]
##title=Edit users
##

from Products.CMFPlone import PloneMessageFactory as _

acl_users = context.acl_users
mtool = context.portal_membership
getMemberById = mtool.getMemberById
mailPassword = context.portal_registration.mailPassword
setMemberProperties = context.plone_utils.setMemberProperties
generatePassword = context.portal_registration.generatePassword

for user in users:
    # Don't bother if the user will be deleted anyway
    if user.id in delete:
        continue

    member = getMemberById(user.id)
    # If email address was changed, set the new one
    if user.email != member.getProperty('email'):
        setMemberProperties(member, email=user.email)

    # If reset password has been checked email user a new password
    if hasattr(user, 'resetpassword'):
        pw = generatePassword()
    else:
        pw = None
        
    acl_users.userFolderEditUser(user.id, pw, user.get('roles',[]), member.getDomains())
    if pw:
        context.REQUEST.form['new_password'] = pw
        mailPassword(user.id, context.REQUEST)

if delete:
    # BBB We should eventually have a global switch to determine member area
    # deletion
    mtool.deleteMembers(delete, delete_memberareas=0, delete_localroles=1)

return state.set(portal_status_message=_(u'Changes applied.'))
