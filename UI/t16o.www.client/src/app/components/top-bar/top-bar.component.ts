import { Component, EventEmitter, Input, OnInit, Output, ViewChild } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { Menu } from 'primeng/menu';

@Component({
  selector: 'app-top-bar',
  templateUrl: './top-bar.component.html',
  styleUrl: './top-bar.component.css',
  standalone: false
})
export class TopBarComponent implements OnInit {
  @Input() title = 'T16O';
  @Input() isMobile = false;
  @Input() darkMode = false;

  @Output() darkModeChange = new EventEmitter<boolean>();
  @Output() menuToggle = new EventEmitter<void>();
  @Output() logoutClick = new EventEmitter<void>();

  public profileMenuItems: MenuItem[] = [];

  @ViewChild('profileMenu') profileMenu!: Menu;

  ngOnInit() {
    this.buildProfileMenu();
  }

  private buildProfileMenu() {
    this.profileMenuItems = [
      {
        label: 'Profile',
        items: [
          {
            label: 'My Account',
            icon: 'pi pi-user'
          },
          {
            label: 'Settings',
            icon: 'pi pi-cog'
          }
        ]
      },
      {
        separator: true
      },
      {
        label: 'Logout',
        icon: 'pi pi-sign-out',
        command: () => this.logoutClick.emit()
      }
    ];
  }

  onDarkModeChange() {
    this.darkModeChange.emit(this.darkMode);
  }

  toggleProfileMenu(event: Event) {
    this.profileMenu.toggle(event);
  }

  onMenuToggle() {
    this.menuToggle.emit();
  }
}
