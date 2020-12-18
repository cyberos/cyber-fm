#include "desktopfile.h"
#include <QFile>
#include <QSettings>
#include <QDebug>

/**
 * @brief Loads desktop file
 * @param fileName
 */
DesktopFile::DesktopFile(const QString &fileName)
{
    // Store file name
    m_fileName = fileName;

    // File validity
    if (m_fileName.isEmpty() || !QFile::exists(fileName)) {
        return;
    }

    QSettings settings(fileName, QSettings::IniFormat);
    settings.beginGroup("Desktop Entry");
    // Loads .desktop file (read from 'Desktop Entry' group)
    m_name = settings.value("Name", settings.value("Name")).toString();
    m_genericName = settings.value("GenericName", settings.value("GenericName")).toString();

    QString nLocalKey = QString("Name[%1]").arg(QLocale::system().name());
    if (settings.contains(nLocalKey)){
        m_localName = settings.value(nLocalKey, m_name).toString();
    } else {
        m_localName = m_name;
    }

    QString gnlocalKey = QString("GenericName[%1]").arg(QLocale::system().name());
    if (settings.contains(gnlocalKey)){
        m_genericName = settings.value(gnlocalKey, m_name).toString();
    } else {
        m_genericName = m_name;
    }

    if (settings.contains("NoDisplay")){
        m_noDisplay = settings.value("NoDisplay", settings.value("NoDisplay").toBool()).toBool();
    }
    if (settings.contains("Hidden")){
        m_hidden = settings.value("Hidden", settings.value("Hidden").toBool()).toBool();
    }

    m_exec = settings.value("Exec", settings.value("Exec")).toString();
    m_icon = settings.value("Icon", settings.value("Icon")).toString();
    m_type = settings.value("Type", settings.value("Type", "Application")).toString();
    m_categories = settings.value("Categories", settings.value("Categories").toString()).toString().remove(" ").split(";");

    m_categories = settings.value("Categories").toString().split(";");

    QString mime_type = settings.value("MimeType", settings.value("MimeType").toString()).toString().remove(" ");

    if (!mime_type.isEmpty())
        m_mimeType = mime_type.split(";");
    // Fix categories
    if (m_categories.first().compare("") == 0) {
        m_categories.removeFirst();
    }
}

QString DesktopFile::getFileName() const
{
    return m_fileName;
}

QString DesktopFile::getPureFileName() const
{
    return m_fileName.split("/").last().remove(".desktop");
}

QString DesktopFile::getName() const {
    return m_name;
}

QString DesktopFile::getLocalName() const
{
    return m_localName;
}

QString DesktopFile::getDisplayName() const
{
    if (!m_genericName.isEmpty()) {
        return m_genericName;
    }
    return m_localName.isEmpty() ? m_name : m_localName;
}

QString DesktopFile::getExec() const
{
    return m_exec;
}

QString DesktopFile::getIcon() const
{
    return m_icon;
}

QString DesktopFile::getType() const
{
    return m_type;
}

bool DesktopFile::getNoShow() const
{
    return m_noDisplay || m_hidden;
}


QStringList DesktopFile::getCategories() const
{
    return m_categories;
}

QStringList DesktopFile::getMimeType() const
{
    return m_mimeType;
}
